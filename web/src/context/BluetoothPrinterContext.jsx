import { createContext, useContext, useState, useEffect } from "react";
import toast from "react-hot-toast";

const BluetoothPrinterContext = createContext();

const LINE_WIDTH = 32;

const center = (text = "") => {
  if (text.length >= LINE_WIDTH) return text.slice(0, LINE_WIDTH);
  const space = Math.floor((LINE_WIDTH - text.length) / 2);
  return " ".repeat(space) + text;
};

const leftRight = (left = "", right = "") => {
  const space = LINE_WIDTH - left.length - right.length;
  return left + " ".repeat(space > 0 ? space : 1) + right;
};

const line = () => "-".repeat(LINE_WIDTH);

const wrapText = (text = "") => {
  const out = [];
  let s = String(text);
  while (s.length > LINE_WIDTH) {
    out.push(s.slice(0, LINE_WIDTH));
    s = s.slice(LINE_WIDTH);
  }
  if (s.length) out.push(s);
  return out;
};

const getItemName = (item) =>
  item?.item?.name ||
  item?.name ||
  item?.product?.name ||
  "-";

export function BluetoothPrinterProvider({ children }) {
  const [device, setDevice] = useState(null);
  const [characteristic, setCharacteristic] = useState(null);
  const [isConnecting, setIsConnecting] = useState(false);

  useEffect(() => {
    return () => {
      if (device?.gatt?.connected) device.gatt.disconnect();
    };
  }, [device]);

  const connectPrinter = async () => {
    if (!navigator.bluetooth) {
      toast.error("Browser tidak support Bluetooth");
      return;
    }

    setIsConnecting(true);

    try {
      const dev = await navigator.bluetooth.requestDevice({
        filters: [
          { namePrefix: "RPP" },
          { namePrefix: "MTP" },
          { namePrefix: "POS" },
          { namePrefix: "BT" },
          { namePrefix: "Printer" },
        ],
        optionalServices: [
          "49535343-fe7d-4ae5-8fa9-9fafd205e455",
          "000018f0-0000-1000-8000-00805f9b34fb",
          "0000ffe0-0000-1000-8000-00805f9b34fb",
        ],
      });

      const server = await dev.gatt.connect();

      const attempts = [
        {
          service: "49535343-fe7d-4ae5-8fa9-9fafd205e455",
          char: "49535343-8841-43f4-a8d4-ecbe34729bb3",
        },
        {
          service: "000018f0-0000-1000-8000-00805f9b34fb",
          char: "00002af1-0000-1000-8000-00805f9b34fb",
        },
        {
          service: "0000ffe0-0000-1000-8000-00805f9b34fb",
          char: "0000ffe1-0000-1000-8000-00805f9b34fb",
        },
      ];

      let ch = null;
      for (const a of attempts) {
        try {
          const svc = await server.getPrimaryService(a.service);
          ch = await svc.getCharacteristic(a.char);
          break;
        } catch (_) {}
      }

      if (!ch) throw new Error("Characteristic tidak ditemukan");

      setDevice(dev);
      setCharacteristic(ch);
      toast.success(`Terhubung ke ${dev.name || "Printer"}`);
    } catch (err) {
      console.error(err);
      toast.error("Gagal connect printer");
    } finally {
      setIsConnecting(false);
    }
  };

  const disconnectPrinter = () => {
    if (device?.gatt?.connected) device.gatt.disconnect();
    setDevice(null);
    setCharacteristic(null);
    toast("Printer terputus");
  };

  const printText = async (text) => {
    if (!characteristic) {
      toast.error("Printer belum terhubung");
      return;
    }

    try {
      const encoder = new TextEncoder();
      const data = encoder.encode(text);
      const chunkSize = 150;

      for (let i = 0; i < data.length; i += chunkSize) {
        await characteristic.writeValueWithoutResponse(
          data.slice(i, i + chunkSize),
        );
        await new Promise((r) => setTimeout(r, 40));
      }
    } catch (err) {
      console.error(err);
      toast.error("Gagal cetak");
    }
  };

  const formatReceipt = ({ transaction }) => {
    const items = transaction?.items || transaction?.Items || [];
    let r = "";

    // HEADER
    r += center("UD. KLAMPIS DEPO") + "\n";
    r += center("085100549376 | 085101381453") + "\n";
    r += line() + "\n";

    const date = new Date(transaction.created_at || Date.now());
    r += center(
      date.toLocaleString("id-ID", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }),
    ) + "\n";
    r += line() + "\n";

    // INFO
    r += leftRight("ID", String(transaction.id)) + "\n";
    r += transaction.transaction_type
      ? leftRight("Type", transaction.transaction_type) + "\n"
      : "";
    r += leftRight("Status", transaction.status || "-") + "\n";
    r += leftRight(
      "Payment",
      (transaction.payment_type || "CASH").toUpperCase(),
    ) + "\n";

    r += line() + "\n";

    // ITEMS
    items.forEach((it) => {
      const nameLines = wrapText(getItemName(it));
      const qty = it.quantity || 0;
      const price = it.price || 0;
      const subtotal = qty * price;

      nameLines.forEach((l) => (r += l + "\n"));
      r +=
        leftRight(
          `${qty} x ${price.toLocaleString("id-ID")}`,
          subtotal.toLocaleString("id-ID"),
        ) + "\n";
    });

    r += line() + "\n";

    // TOTALS (SAMA DENGAN MODAL)
    const itemsTotal = items.reduce(
      (sum, it) => sum + (it.price || 0) * (it.quantity || 0),
      0,
    );

    r += leftRight("Total", itemsTotal.toLocaleString("id-ID")) + "\n";

    if (transaction.discount > 0) {
      r += leftRight(
        "Discount",
        transaction.discount.toLocaleString("id-ID"),
      ) + "\n";
    }

    if (transaction.payment) {
      r += leftRight(
        "Paid",
        transaction.payment.toLocaleString("id-ID"),
      ) + "\n";
    }

    if (transaction.change !== undefined) {
      r += leftRight(
        "Change",
        transaction.change.toLocaleString("id-ID"),
      ) + "\n";
    }

    if (transaction.note) {
      r += line() + "\n";
      wrapText(`Note: ${transaction.note}`).forEach(
        (l) => (r += l + "\n"),
      );
    }

    r += line() + "\n";
    r += center("Terima Kasih") + "\n";
    r += center("🙏") + "\n\n\n";

    return r;
  };

  const printReceipt = async (data) => {
    await printText(formatReceipt(data));
    toast.success("Struk dicetak");
  };

  return (
    <BluetoothPrinterContext.Provider
      value={{
        device,
        characteristic,
        isConnecting,
        connectPrinter,
        disconnectPrinter,
        printText,
        printReceipt,
      }}
    >
      {children}
    </BluetoothPrinterContext.Provider>
  );
}

//hook 
export const useBluetoothPrinter = () => {
  const ctx = useContext(BluetoothPrinterContext);
  if (!ctx) {
    throw new Error(
      "useBluetoothPrinter must be used inside BluetoothPrinterProvider",
    );
  }
  return ctx;
};

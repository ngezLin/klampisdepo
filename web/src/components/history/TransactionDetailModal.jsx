import React, { useRef } from "react";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import { useBluetoothPrinter } from "../../context/BluetoothPrinterContext";
import toast from "react-hot-toast";

export default function TransactionDetailModal({
  isOpen,
  onClose,
  transaction,
}) {
  const componentRef = useRef();

  const {
    device,
    isConnecting,
    connectPrinter,
    disconnectPrinter,
    printReceipt,
  } = useBluetoothPrinter();

  if (!isOpen || !transaction) return null;

  const items = transaction?.items || transaction?.Items || [];

  const handlePrintReceipt = async () => {
    if (!device) {
      toast.error("Printer belum terhubung");
      return;
    }

    try {
      await printReceipt({ transaction, type: "completed" });
      // sukses sudah ditangani di context (kalau mau)
    } catch (err) {
      toast.error("Gagal mencetak");
    }
  };

  // Download PDF
  const handleDownloadPDF = async () => {
    const element = componentRef.current;
    if (!element) return;

    try {
      const canvas = await html2canvas(element, { scale: 2 });
      const imgData = canvas.toDataURL("image/png");

      const pdf = new jsPDF({
        orientation: "portrait",
        unit: "px",
        format: [canvas.width, canvas.height],
      });

      pdf.addImage(imgData, "PNG", 0, 0, canvas.width, canvas.height);
      pdf.save(`transaction-${transaction.id}.pdf`);

      toast.success("PDF berhasil diunduh");
    } catch (error) {
      console.error(error);
      toast.error("Gagal membuat PDF");
    }
  };

  const itemsTotal = items.reduce(
    (sum, it) => sum + (it.price || 0) * (it.quantity || 0),
    0
  );

  const date = new Date(transaction.created_at || Date.now());
  const formattedDate = date.toLocaleString("id-ID", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/60 z-50">
      <div className="bg-white p-6 rounded-2xl shadow-lg w-[400px] max-h-[90vh] overflow-y-auto">
        <div ref={componentRef} className="text-sm font-mono">
          <h2 className="text-center font-bold text-lg mb-2">
            UD. KLAMPIS DEPO
          </h2>
          <p className="text-center mb-1">085100549376 | 085101381453</p>
          <p className="text-center mb-2">{formattedDate}</p>

          <p>ID: {transaction.id}</p>
          {transaction.transaction_type && (
            <p>Type: {transaction.transaction_type}</p>
          )}
          <p>Status: {transaction.status}</p>
          <p>Payment: {transaction.payment_type}</p>
          <p>Total: Rp {transaction.total?.toLocaleString() || 0}</p>
          {transaction.note && <p>Note: {transaction.note}</p>}

          <hr className="my-2" />

          <p className="font-semibold mb-1">Items:</p>
          {items.length > 0 ? (
            items.map((it, idx) => (
              <div key={it.item_id || idx} className="flex justify-between">
                <div>
                  {it.item?.name || "-"}
                  <div className="text-xs">
                    {it.quantity} x {it.price?.toLocaleString() || 0}
                  </div>
                </div>
                <span>
                  Rp {(it.price * it.quantity)?.toLocaleString() || 0}
                </span>
              </div>
            ))
          ) : (
            <p className="text-center text-gray-500">No items</p>
          )}

          <hr className="my-2" />

          <div className="flex justify-between">
            <span>Total</span>
            <span>Rp {itemsTotal.toLocaleString()}</span>
          </div>

          {transaction.discount > 0 && (
            <div className="flex justify-between">
              <span>Discount</span>
              <span>Rp {transaction.discount.toLocaleString()}</span>
            </div>
          )}

          {transaction.payment && (
            <div className="flex justify-between">
              <span>Paid</span>
              <span>Rp {transaction.payment.toLocaleString()}</span>
            </div>
          )}

          {transaction.change !== undefined && (
            <div className="flex justify-between">
              <span>Change</span>
              <span>Rp {transaction.change.toLocaleString()}</span>
            </div>
          )}

          <p className="text-center mt-4 font-semibold">Terima Kasih 🙏</p>
        </div>

        <div className="flex flex-wrap justify-between mt-6 gap-2">
          <button
            onClick={connectPrinter}
            disabled={isConnecting || device}
            className={`px-4 py-2 rounded w-full sm:w-auto text-white ${
              device
                ? "bg-green-500"
                : isConnecting
                ? "bg-blue-400"
                : "bg-blue-600 hover:bg-blue-700"
            } disabled:opacity-50`}
          >
            {device
              ? `✅ ${device.name || "Connected"}`
              : isConnecting
              ? "🔄 Connecting..."
              : "🔗 Connect Printer"}
          </button>

          {device && (
            <button
              onClick={() => {
                disconnectPrinter();
                toast("Printer terputus");
              }}
              className="bg-orange-600 hover:bg-orange-700 text-white px-4 py-2 rounded w-full sm:w-auto"
            >
              🔌 Disconnect
            </button>
          )}

          <button
            onClick={handlePrintReceipt}
            disabled={!device}
            className={`px-4 py-2 rounded w-full sm:w-auto text-white ${
              device
                ? "bg-green-600 hover:bg-green-700"
                : "bg-gray-400 opacity-50 cursor-not-allowed"
            }`}
          >
            🖨️ Print
          </button>

          <button
            onClick={handleDownloadPDF}
            className="bg-gray-700 hover:bg-gray-800 text-white px-4 py-2 rounded w-full sm:w-auto"
          >
            💾 PDF
          </button>

          <button
            onClick={onClose}
            className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded w-full sm:w-auto"
          >
            ❌ Close
          </button>
        </div>
      </div>
    </div>
  );
}

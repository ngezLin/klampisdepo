import { useEffect } from "react";
import toast from "react-hot-toast";

export default function Cart({
  cart,
  updateQuantity,
  removeFromCart,
  paymentAmount,
  setPaymentAmount,
  paymentType,
  setPaymentType,
  transactionType,
  setTransactionType,
  handleCheckout,
  openModal,
  note,
  setNote,
  discount,
  setDiscount,
  // 🔥 SIMPLIFIED: Props bluetooth
  device,
  isConnecting,
  connectPrinter,
  disconnectPrinter,
  printReceipt,
}) {
  useEffect(() => {
    const totalBeforeDiscount = cart.reduce(
      (acc, c) => acc + c.price * c.quantity,
      0,
    );
    const total = Math.max(totalBeforeDiscount - discount, 0);
    if (paymentType !== "cash") {
      setPaymentAmount(total);
    }
  }, [paymentType, cart, discount, setPaymentAmount]);

  const formatNumber = (num) => {
    if (isNaN(num)) return "0";
    return num.toLocaleString("id-ID");
  };

  const normalizeNumber = (val) => {
    if (!val) return 0;
    const n = parseInt(val.toString().replace(/^0+/, "")) || 0;
    return n;
  };

  const totalBeforeDiscount = cart.reduce(
    (acc, c) => acc + c.price * c.quantity,
    0,
  );
  const total = Math.max(totalBeforeDiscount - discount, 0);
  const change = paymentAmount - total;

  // 🔥 SIMPLIFIED: Print preview
  const handlePrintPreview = () => {
    if (!device) {
      toast.error("⚠️ Hubungkan printer dulu!");
      return;
    }
    if (cart.length === 0) {
      toast.error("⚠️ Cart kosong!");
      return;
    }

    printReceipt({
      type: "preview",
      cart,
      transaction: { total, discount, note, transaction_type: transactionType },
    });
  };

  return (
    <div className="w-full md:w-1/3 bg-gray-900/50 backdrop-blur-sm p-4 rounded-xl shadow-inner overflow-y-auto border border-white/5">
      <h2 className="text-xl font-bold mb-4 text-white">Cart</h2>

      {cart.length === 0 && <p className="text-gray-500 italic">Cart kosong</p>}

      <div className="space-y-2">
        {cart.map((c) => (
          <div
            key={c.item_id}
            className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 p-3 bg-gray-800 border border-white/5 rounded-xl shadow-sm"
          >
            <div className="flex-1">
              <p className="font-semibold text-white">{c.name}</p>

              <div className="flex items-center gap-2">
                <label className="text-sm">Harga:</label>
                <input
                  type="number"
                  value={c.price}
                  onChange={(e) =>
                    updateQuantity(
                      c.item_id,
                      c.quantity,
                      normalizeNumber(e.target.value),
                    )
                  }
                  className="w-24 bg-gray-700 border-gray-600 rounded px-2 py-0.5 text-right text-sm text-white"
                />
              </div>
            </div>

            <div className="flex items-center gap-2 w-full sm:w-auto">
              <input
                type="number"
                value={c.quantity}
                onChange={(e) =>
                  updateQuantity(
                    c.item_id,
                    normalizeNumber(e.target.value),
                    c.price,
                  )
                }
                className="w-16 bg-gray-700 border-gray-600 rounded px-2 py-0.5 text-center text-white"
              />
              <button
                className="text-red-500 text-sm"
                onClick={() => removeFromCart(c.item_id)}
              >
                Remove
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-4 space-y-3">
        <div className="flex justify-between items-center text-gray-300">
          <label className="font-semibold text-sm">Discount</label>
          <input
            type="number"
            value={discount}
            min={0}
            onChange={(e) => setDiscount(normalizeNumber(e.target.value))}
            className="w-32 bg-gray-800 border-gray-700 rounded px-3 py-1.5 text-sm text-white text-right"
          />
        </div>

        <p className="text-lg font-bold">Total: Rp {formatNumber(total)}</p>

        <div>
          <label className="block mb-1 font-semibold text-sm text-gray-300">
            Transaction Type
          </label>
          <select
            value={transactionType}
            onChange={(e) => setTransactionType(e.target.value)}
            className="w-full bg-gray-800 border-gray-700 rounded-lg px-3 py-2 text-sm text-white"
          >
            <option value="onsite">Onsite</option>
            <option value="deliver">Deliver</option>
          </select>
        </div>

        <div>
          <label className="block mb-1 font-semibold text-sm text-gray-300">
            Note
          </label>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="Tambahkan catatan..."
            className="w-full bg-gray-800 border-gray-700 rounded-lg px-3 py-2 text-sm text-white resize-none h-20"
          />
        </div>

        <div>
          <label className="block mb-1 font-semibold text-sm text-gray-300">
            Payment (Rp)
          </label>
          <input
            type="text"
            value={paymentAmount > 0 ? formatNumber(paymentAmount) : ""}
            onChange={(e) => {
              const val = e.target.value.replace(/\./g, "");
              setPaymentAmount(normalizeNumber(val));
            }}
            className="w-full bg-gray-800 border-gray-700 rounded-lg px-3 py-2 text-sm text-white font-bold"
            disabled={paymentType !== "cash"}
          />
        </div>

        {paymentAmount > 0 && (
          <p
            className={`font-semibold ${
              change < 0 ? "text-red-500" : "text-green-600"
            }`}
          >
            Change: Rp {formatNumber(change >= 0 ? change : 0)}{" "}
            {change < 0 && "(Insufficient)"}
          </p>
        )}

        <div>
          <label className="block mb-1 font-semibold text-sm text-gray-300">
            Payment Type
          </label>
          <select
            value={paymentType}
            onChange={(e) => setPaymentType(e.target.value)}
            className="w-full bg-gray-800 border-gray-700 rounded-lg px-3 py-2 text-sm text-white"
          >
            <option value="cash">Cash</option>
            <option value="qris">Transfer</option>
            <option value="debit">Debit</option>
            <option value="credit">Credit</option>
          </select>
        </div>

        <div className="flex flex-col sm:flex-row gap-2">
          <button
            className={`flex-1 bg-green-500 text-white font-bold px-4 py-3 sm:py-2 rounded shadow-sm ${
              change < 0
                ? "opacity-50 cursor-not-allowed"
                : "hover:bg-green-600 active:scale-95 transition-transform"
            }`}
            disabled={change < 0}
            onClick={() => handleCheckout("completed", discount)}
          >
            Checkout
          </button>
          <button
            className="flex-1 bg-yellow-500 hover:bg-yellow-600 font-bold active:scale-95 transition-transform text-white px-4 py-3 sm:py-2 rounded shadow-sm"
            onClick={() => handleCheckout("draft", discount)}
          >
            Save Draft
          </button>
        </div>

        {/* 🔥 SIMPLIFIED: Bluetooth Controls */}
        <div className="flex flex-col sm:flex-row gap-2">
          <button
            onClick={connectPrinter}
            disabled={isConnecting || device}
            className={`flex-1 px-4 py-3 sm:py-2 rounded font-bold text-white text-sm shadow-sm active:scale-95 transition-transform ${
              device
                ? "bg-green-500"
                : isConnecting
                  ? "bg-blue-400"
                  : "bg-blue-600 hover:bg-blue-700"
            } ${(isConnecting || device) && "opacity-70 cursor-not-allowed"}`}
          >
            {device
              ? `✅ ${device.name || "Connected"}`
              : isConnecting
                ? "🔄 Connecting..."
                : "🔗 Connect Printer"}
          </button>

          {device && (
            <button
              onClick={disconnectPrinter}
              className="flex-1 px-4 py-3 sm:py-2 rounded font-bold text-white text-sm bg-red-500 hover:bg-red-600 shadow-sm active:scale-95 transition-transform"
            >
              🔌 Disconnect
            </button>
          )}
        </div>

        <div className="flex flex-col sm:flex-row gap-2">
          <button
            className={`flex-1 bg-purple-500 font-bold text-white px-4 py-3 sm:py-2 rounded shadow-sm active:scale-95 transition-transform ${
              cart.length === 0 || !device
                ? "opacity-50 cursor-not-allowed"
                : "hover:bg-purple-600"
            }`}
            onClick={handlePrintPreview}
            disabled={cart.length === 0 || !device}
          >
            🖨️ Print Preview
          </button>

          <button
            className="flex-1 bg-blue-500 hover:bg-blue-600 font-bold text-white px-4 py-3 sm:py-2 rounded shadow-sm active:scale-95 transition-transform"
            onClick={openModal}
          >
            📋 Load Draft
          </button>
        </div>
      </div>
    </div>
  );
}

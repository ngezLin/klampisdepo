import React, { useRef } from "react";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import { useBluetoothPrinter } from "../../context/BluetoothPrinterContext";
import toast from "react-hot-toast";
import StatusBadge from "../common/StatusBadge";

// StatusBadge is now imported from shared components

export default function ReceiptModal({ isOpen, onClose, transaction }) {
  const componentRef = useRef();

  const { device, printReceipt } = useBluetoothPrinter();

  if (!isOpen || !transaction) return null;

  const items = transaction.items || transaction.Items || [];

  const handlePrintReceipt = async () => {
    if (!device) {
      toast.error("Printer belum terhubung");
      return;
    }
    try {
      await printReceipt({ transaction, type: "completed" });
    } catch (err) {
      toast.error("Gagal mencetak");
    }
  };

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
      pdf.save(`receipt-${transaction.id}.pdf`);

      toast.success("PDF berhasil diunduh");
    } catch (error) {
      console.error(error);
      toast.error("Gagal membuat PDF");
    }
  };

  const itemsTotal = items.reduce(
    (sum, it) => sum + (it.price || 0) * (it.quantity || 0),
    0,
  );

  const date = new Date(
    transaction.created_at || transaction.createdAt || Date.now(),
  );
  const formattedDate = date.toLocaleString("id-ID", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/80 backdrop-blur-sm z-50 p-4">
      <div className="bg-gray-900 border border-white/10 p-8 rounded-3xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-500 hover:text-white transition-colors"
        >
          <svg
            className="w-6 h-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>

        <div
          ref={componentRef}
          className="text-sm font-mono text-gray-100 bg-gray-950 p-6 rounded-2xl border border-dashed border-gray-700"
        >
          <div className="text-center mb-6">
            <h2 className="font-black text-2xl tracking-tighter text-white mb-1 uppercase">
              UD. KLAMPIS DEPO
            </h2>
            <div className="w-12 h-1 bg-blue-500 mx-auto rounded-full mb-3" />
            <p className="text-gray-400 text-xs tracking-widest uppercase">
              Official Transaction Receipt
            </p>
          </div>

          <div className="grid grid-cols-2 gap-y-2 mb-6 text-xs border-b border-gray-800 pb-4">
            <span className="text-gray-500 uppercase font-bold">
              Receipt ID
            </span>
            <span className="text-right text-blue-400 font-bold">
              #{transaction.id}
            </span>
            <span className="text-gray-500 uppercase font-bold">Date</span>
            <span className="text-right">{formattedDate}</span>
            <span className="text-gray-500 uppercase font-bold">Status</span>
            <span className="text-right">
              <StatusBadge status={transaction.status} size="xs" />
            </span>
          </div>

          <div className="space-y-3 mb-6">
            <div className="flex justify-between items-center text-xs text-gray-500 font-bold uppercase tracking-widest">
              <span>Item Description</span>
              <span>Subtotal</span>
            </div>
            <div className="space-y-4">
              {items.length > 0 ? (
                items.map((it, idx) => (
                  <div
                    key={it.item_id || idx}
                    className="flex justify-between items-start gap-4"
                  >
                    <div className="flex-1">
                      <p className="text-white font-bold leading-tight">
                        {it.item?.name || "-"}
                      </p>
                      <p className="text-[10px] text-gray-500 mt-0.5">
                        {it.quantity} units x Rp {it.price?.toLocaleString()}
                      </p>
                    </div>
                    <span className="text-gray-300 font-medium shrink-0">
                      Rp {(it.price * it.quantity)?.toLocaleString()}
                    </span>
                  </div>
                ))
              ) : (
                <p className="text-center py-4 text-gray-600 italic">
                  No line items recorded
                </p>
              )}
            </div>
          </div>

          <div className="border-t border-gray-800 pt-4 space-y-2 mb-6">
            <div className="flex justify-between text-gray-400">
              <span>Subtotal</span>
              <span>Rp {itemsTotal.toLocaleString()}</span>
            </div>
            {transaction.discount > 0 && (
              <div className="flex justify-between text-red-400">
                <span>Discount</span>
                <span>-Rp {transaction.discount.toLocaleString()}</span>
              </div>
            )}
            <div className="flex justify-between text-white font-black text-lg pt-1">
              <span>TOTAL DUE</span>
              <span className="text-blue-400">
                Rp {transaction.total?.toLocaleString() || 0}
              </span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-1 text-[10px] text-gray-500 mb-6 font-medium">
            <span>Payment: {transaction.payment_type || "Cash"}</span>
            {transaction.payment && (
              <span className="text-right">
                Paid: Rp {transaction.payment.toLocaleString()}
              </span>
            )}
            {transaction.payment - transaction.total > 0 && (
              <span className="text-right col-span-2">
                Change: Rp{" "}
                {(transaction.payment - transaction.total).toLocaleString()}
              </span>
            )}
          </div>

          <div className="text-center pt-4 border-t border-gray-800">
            <p className="text-[10px] text-gray-500 leading-relaxed uppercase tracking-widest">
              Thank you for choosing KlampisDepo.
              <br />
              Please visit us again!
            </p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3 mt-8">
          <button
            onClick={handlePrintReceipt}
            disabled={!device}
            className={`px-4 py-3 rounded-2xl flex items-center justify-center gap-2 text-sm font-bold transition-all active:scale-95 ${
              device
                ? "bg-green-600 text-white shadow-lg shadow-green-600/20 hover:bg-green-700"
                : "bg-gray-800 text-gray-600 border border-white/5 cursor-not-allowed"
            }`}
          >
            🖨️ Print Receipt
          </button>

          <button
            onClick={handleDownloadPDF}
            className="bg-gray-800 hover:bg-gray-700 text-white px-4 py-3 rounded-2xl text-sm font-bold active:scale-95 transition-all border border-white/5"
          >
            💾 Download PDF
          </button>
        </div>
      </div>
    </div>
  );
}

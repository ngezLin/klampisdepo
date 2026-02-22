import React, { useRef } from "react";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import { useBluetoothPrinter } from "../../context/BluetoothPrinterContext";
import toast from "react-hot-toast";

export default function ReceiptModal({ isOpen, onClose, transaction }) {
  const componentRef = useRef();
  // 🔥 SIMPLIFIED: Ambil dari context
  const { device, printReceipt } = useBluetoothPrinter();

  if (!isOpen || !transaction) return null;

  const items = transaction.items || [];

  const formatNumber = (num) => {
    if (isNaN(num)) return "0";
    return num.toLocaleString("id-ID");
  };

  // 🔥 SIMPLIFIED: Print langsung pakai context
  const handlePrintReceipt = () => {
    if (!device) {
      toast("⚠️ Printer belum terhubung!");
      return;
    }
    printReceipt({ transaction, type: "completed" });
  };

  const handleDownloadPDF = async () => {
    try {
      const canvas = await html2canvas(componentRef.current);
      const imgData = canvas.toDataURL("image/png");
      const pdf = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [80, 200],
      });

      const imgWidth = 80;
      const imgHeight = (canvas.height * imgWidth) / canvas.width;

      pdf.addImage(imgData, "PNG", 0, 0, imgWidth, imgHeight);
      pdf.save(`receipt-${transaction.id}.pdf`);
    } catch (error) {
      console.error("Error generating PDF:", error);
      toast.error("Gagal membuat PDF");
    }
  };

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-white p-6 rounded-xl w-full max-w-[400px]">
        <h2 className="text-xl font-bold mb-4 text-center">Receipt</h2>

        <div
          ref={componentRef}
          className="font-mono text-sm bg-gray-50 p-4 rounded"
        >
          <div className="text-center font-bold mb-2">UD. KLAMPIS DEPO</div>
          <div className="text-center text-xs mb-2">
            085100549376 | 085101381453
          </div>
          <div className="text-center text-xs mb-4">
            {new Date(transaction.createdAt || new Date()).toLocaleString(
              "id-ID"
            )}
          </div>

          <div className="border-t border-dashed border-gray-400 pt-2">
            {items.map((it, i) => (
              <div key={i} className="mb-2">
                <div className="font-semibold">{it.item?.name || "Item"}</div>
                <div className="flex justify-between text-xs">
                  <span>
                    {it.quantity} x Rp {formatNumber(it.price)}
                  </span>
                  <span>Rp {formatNumber(it.price * it.quantity)}</span>
                </div>
              </div>
            ))}
          </div>

          <div className="border-t border-dashed border-gray-400 mt-2 pt-2">
            {transaction.discount > 0 && (
              <div className="flex justify-between text-sm mb-1">
                <span>Discount:</span>
                <span>Rp {formatNumber(transaction.discount)}</span>
              </div>
            )}
            <div className="flex justify-between font-bold text-lg">
              <span>TOTAL:</span>
              <span>Rp {formatNumber(transaction.total)}</span>
            </div>
            {transaction.payment && (
              <>
                <div className="flex justify-between text-sm mt-1">
                  <span>Paid:</span>
                  <span>Rp {formatNumber(transaction.payment)}</span>
                </div>
                {transaction.payment - transaction.total > 0 && (
                  <div className="flex justify-between text-sm">
                    <span>Change:</span>
                    <span>
                      Rp {formatNumber(transaction.payment - transaction.total)}
                    </span>
                  </div>
                )}
              </>
            )}
          </div>

          <div className="text-center mt-4 text-sm">Terima Kasih 🙏</div>
        </div>

        <div className="flex gap-2 mt-4">
          <button
            onClick={handlePrintReceipt}
            disabled={!device}
            className={`flex-1 text-white px-4 py-2 rounded ${
              device
                ? "bg-green-600 hover:bg-green-700"
                : "bg-gray-400 opacity-50 cursor-not-allowed"
            }`}
          >
            🖨️ Print
          </button>
          <button
            onClick={handleDownloadPDF}
            className="flex-1 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            📄 PDF
          </button>
          <button
            onClick={onClose}
            className="flex-1 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
          >
            ✕ Close
          </button>
        </div>
      </div>
    </div>
  );
}

import { BLEPrinter } from "react-native-thermal-receipt-printer-image-qr";
import { Alert } from "react-native";

export const printReceipt = async (transaction: any) => {
  try {
    const transactionDate =
      new Date(transaction.created_at || Date.now()).toLocaleString() || "-";

    // Check if printer is connected. The PrinterContext handles the connection,
    // but we can just blindly attempt to print via the BLEPrinter module since it holds the connection natively,
    // or we can just try/catch if it fails.

    let textToPrint = "";

    // Header
    textToPrint += "<C>KLAMPIS DEPO</C>\n";
    textToPrint += "<C>Receipt</C>\n";
    textToPrint += "--------------------------------\n";

    // Info
    textToPrint += `Trx ID : #${transaction.id || "-"}\n`;
    textToPrint += `Date   : ${transactionDate}\n`;
    textToPrint += `Status : ${transaction.status?.toUpperCase() || "-"}\n`;
    textToPrint += `Payment: ${transaction.paymentType?.toUpperCase() || "-"}\n`;
    textToPrint += "--------------------------------\n";

    // Items
    textToPrint += "Item          Qty   Price   Subt\n";
    textToPrint += "--------------------------------\n";

    transaction.items?.forEach((item: any) => {
      const name = (item.name || item.item?.name || "")
        .substring(0, 12)
        .padEnd(12);
      const qty = String(item.quantity).padEnd(3);
      const price = String(item.price || item.customPrice || 0).padEnd(7);
      const subt = String(
        (item.price || item.customPrice || 0) * item.quantity,
      ).padEnd(7);

      textToPrint += `${name} ${qty} ${price} ${subt}\n`;
    });

    textToPrint += "--------------------------------\n";

    // Totals
    const discount = String(transaction.discount || 0);
    const total = String(transaction.total || transaction.paymentAmount || 0);

    textToPrint += `<R>Discount: Rp ${discount}</R>\n`;
    textToPrint += `<R>Total   : Rp ${total}</R>\n`;
    textToPrint += "\n";
    textToPrint += "<C>Terima kasih atas kunjungan Anda</C>\n";
    textToPrint += "\n\n\n"; // Feed lines

    await BLEPrinter.printBill(textToPrint);
  } catch (error) {
    console.error("Error printing receipt natively:", error);
    Alert.alert(
      "Print Error",
      "Failed to print to bluetooth printer. Please check Printer settings.",
    );
  }
};

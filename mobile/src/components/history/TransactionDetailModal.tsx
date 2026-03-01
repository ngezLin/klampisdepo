import { View, Modal, TouchableOpacity, Text, StyleSheet } from "react-native";
import TransactionDetail from "./TransactionDetail";
import { printReceipt } from "../../utils/print";

export default function TransactionDetailModal({
  visible,
  transaction,
  onClose,
}: {
  visible: boolean;
  transaction: any;
  onClose: () => void;
}) {
  return (
    <Modal visible={visible} animationType="slide">
      <View style={{ flex: 1, padding: 16 }}>
        <TransactionDetail transaction={transaction} />

        <View style={styles.actionRow}>
          <TouchableOpacity
            onPress={() => printReceipt(transaction)}
            style={styles.printBtn}
          >
            <Text style={styles.printText}>Print Receipt</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={onClose} style={styles.closeBtn}>
            <Text style={styles.closeText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  actionRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 20,
  },
  printBtn: {
    backgroundColor: "#2563eb",
    padding: 10,
    borderRadius: 6,
    flex: 1,
    marginRight: 10,
    alignItems: "center",
  },
  printText: {
    color: "#fff",
    fontWeight: "bold",
  },
  closeBtn: {
    borderWidth: 1,
    borderColor: "#dc2626",
    padding: 10,
    borderRadius: 6,
    flex: 1,
    alignItems: "center",
  },
  closeText: {
    color: "#dc2626",
    fontWeight: "bold",
  },
});

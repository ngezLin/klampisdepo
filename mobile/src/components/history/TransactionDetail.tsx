import { View, Text, StyleSheet } from "react-native";

export default function TransactionDetail({
  transaction,
}: {
  transaction: any;
}) {
  if (!transaction) return null;

  return (
    <View style={styles.container}>
      {/* HEADER */}
      <View style={styles.header}>
        <Text style={styles.title}>Transaction #{transaction.id}</Text>
        <Text style={styles.status}>{transaction.status.toUpperCase()}</Text>
      </View>

      {/* SUMMARY */}
      <View style={styles.summary}>
        <Text style={styles.label}>
          Date
          <Text style={styles.value}>
            {" "}
            {new Date(transaction.created_at).toLocaleString()}
          </Text>
        </Text>

        <Text style={styles.label}>
          Total
          <Text style={styles.total}> Rp {transaction.total}</Text>
        </Text>
      </View>

      {/* ITEMS */}
      <Text style={styles.section}>Items</Text>

      {transaction.items?.map((it: any, idx: number) => (
        <View key={idx} style={styles.itemRow}>
          <Text style={styles.itemName}>{it.item?.name}</Text>
          <Text style={styles.itemQty}>x{it.quantity}</Text>
          <Text style={styles.itemPrice}>Rp {it.price}</Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: "#fff",
    padding: 14,
    borderRadius: 10,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 6,
  },
  title: {
    fontSize: 18,
    fontWeight: "bold",
  },
  status: {
    fontSize: 12,
    fontWeight: "bold",
    color: "#2563eb",
  },
  summary: {
    marginTop: 4,
    marginBottom: 10,
  },
  label: {
    color: "#475569",
    marginTop: 2,
  },
  value: {
    color: "#000",
  },
  total: {
    fontWeight: "bold",
    fontSize: 16,
    color: "#16a34a",
  },
  section: {
    fontWeight: "bold",
    marginBottom: 6,
    borderBottomWidth: 1,
    paddingBottom: 4,
  },
  itemRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingVertical: 4,
  },
  itemName: {
    flex: 1,
    fontWeight: "500",
  },
  itemQty: {
    width: 40,
    textAlign: "center",
  },
  itemPrice: {
    width: 90,
    textAlign: "right",
    fontWeight: "500",
  },
});

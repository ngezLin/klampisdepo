import { View, Text, TouchableOpacity } from "react-native";

export default function TransactionCard({
  transaction,
  onPress,
}: {
  transaction: any;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity
      onPress={onPress}
      style={{
        borderWidth: 1,
        borderRadius: 8,
        padding: 12,
        marginBottom: 10,
      }}
    >
      <Text style={{ fontWeight: "bold", fontSize: 16 }}>
        Transaction #{transaction.id}
      </Text>

      <Text>Status: {transaction.status}</Text>
      <Text>Total: {transaction.total}</Text>
      <Text>Date: {new Date(transaction.created_at).toLocaleString()}</Text>
    </TouchableOpacity>
  );
}

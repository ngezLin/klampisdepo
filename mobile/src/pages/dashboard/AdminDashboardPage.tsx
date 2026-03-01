import { useEffect, useState } from "react";
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
} from "react-native";
import { getDashboard } from "../../services/dashboard.service";

export default function AdminDashboardPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      const res = await getDashboard();
      setData(res.data);
    } catch (err) {
      console.log(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (!data) {
    return (
      <View style={styles.center}>
        <Text>Dashboard unavailable</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      {/* SUMMARY */}
      <Text style={styles.title}>Dashboard</Text>

      <View style={styles.card}>
        <Text>Today Profit</Text>
        <Text style={styles.value}>Rp {data.today_profit}</Text>
      </View>

      <View style={styles.card}>
        <Text>Today Transactions</Text>
        <Text style={styles.value}>{data.today_transactions}</Text>
      </View>

      <View style={styles.card}>
        <Text>Low Stock Items</Text>
        <Text style={styles.value}>{data.low_stock}</Text>
      </View>

      <View style={styles.card}>
        <Text>Delivery Today</Text>
        <Text style={styles.value}>{data.today_delivery}</Text>
      </View>

      {/* TOP SELLING */}
      <Text style={styles.section}>Top Selling Items</Text>
      {data.top_selling_items.map((item: any) => (
        <View key={item.item_id} style={styles.row}>
          <Text>{item.name}</Text>
          <Text>{item.quantity}</Text>
        </View>
      ))}

      {/* RECENT TRANSACTIONS */}
      <Text style={styles.section}>Recent Transactions</Text>
      {data.recent_transactions.map((trx: any) => (
        <View key={trx.id} style={styles.card}>
          <Text style={{ fontWeight: "bold" }}>Transaction #{trx.id}</Text>

          {trx.items.map((it: any, idx: number) => (
            <Text key={idx}>
              - {it.name} x{it.quantity} (Rp {it.subtotal})
            </Text>
          ))}
        </View>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  center: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  title: {
    fontSize: 20,
    fontWeight: "bold",
    marginBottom: 12,
  },
  section: {
    fontSize: 16,
    fontWeight: "bold",
    marginTop: 20,
    marginBottom: 8,
  },
  card: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
  },
  value: {
    fontSize: 18,
    fontWeight: "bold",
  },
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingVertical: 6,
    borderBottomWidth: 0.5,
  },
});

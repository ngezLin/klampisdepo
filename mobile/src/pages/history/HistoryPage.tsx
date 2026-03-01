import { useEffect, useState } from "react";
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Platform,
  Modal,
} from "react-native";
import DateTimePicker from "@react-native-community/datetimepicker";
import { getTransactionHistory } from "../../services/history.service";
import TransactionDetailModal from "../../components/history/TransactionDetailModal";

export default function HistoryPage() {
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [showPicker, setShowPicker] = useState(false);

  const [selected, setSelected] = useState<any>(null);
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    fetchHistory(1, true);
  }, []);

  const fetchHistory = async (
    pageNumber = 1,
    refresh = false,
    date?: Date | null
  ) => {
    try {
      setLoading(true);

      const formattedDate = date ? date.toISOString().split("T")[0] : undefined;

      const res = await getTransactionHistory(pageNumber, 10, formattedDate);

      setTotalPages(res.data.totalPages);
      setData((prev) =>
        refresh ? res.data.data : [...prev, ...res.data.data]
      );
    } catch (err) {
      console.log(err);
    } finally {
      setLoading(false);
    }
  };

  const loadMore = () => {
    if (loading || page >= totalPages) return;
    const next = page + 1;
    setPage(next);
    fetchHistory(next, false, selectedDate);
  };

  return (
    <View style={{ flex: 1, padding: 16 }}>
      <Text style={{ fontSize: 20, fontWeight: "bold" }}>
        Transaction History
      </Text>

      {/* DATE FILTER */}
      <TouchableOpacity
        onPress={() => setShowPicker(true)}
        style={{
          marginVertical: 10,
          padding: 10,
          borderWidth: 1,
          borderRadius: 6,
        }}
      >
        <Text>
          {selectedDate ? selectedDate.toDateString() : "Filter by date"}
        </Text>
      </TouchableOpacity>

      {showPicker && (
        <DateTimePicker
          value={selectedDate || new Date()}
          mode="date"
          display={Platform.OS === "ios" ? "inline" : "default"}
          onChange={(_, date) => {
            setShowPicker(false);
            if (date) {
              setSelectedDate(date);
              setPage(1);
              fetchHistory(1, true, date);
            }
          }}
        />
      )}

      {/* LIST */}
      <FlatList
        data={data}
        keyExtractor={(item) => item.id.toString()}
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        refreshing={loading}
        onRefresh={() => {
          setPage(1);
          fetchHistory(1, true, selectedDate);
        }}
        ListFooterComponent={loading ? <ActivityIndicator /> : null}
        renderItem={({ item }) => (
          <TouchableOpacity
            onPress={() => {
              setSelected(item);
              setModalVisible(true);
            }}
            style={{
              borderWidth: 1,
              borderRadius: 8,
              padding: 12,
              marginBottom: 10,
            }}
          >
            <Text style={{ fontWeight: "bold" }}>Transaction #{item.id}</Text>
            <Text>Status: {item.status}</Text>
            <Text>Total: {item.total}</Text>
            <Text>Date: {new Date(item.created_at).toLocaleString()}</Text>
          </TouchableOpacity>
        )}
      />
      <TransactionDetailModal
        visible={modalVisible}
        transaction={selected}
        onClose={() => setModalVisible(false)}
      />
    </View>
  );
}

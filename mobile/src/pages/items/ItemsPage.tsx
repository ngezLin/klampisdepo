import { useEffect, useState } from "react";
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  Alert,
  TextInput,
  Image,
} from "react-native";
import {
  getItems,
  deleteItem,
  searchItems,
} from "../../services/items.service";
import { useNavigation } from "@react-navigation/native";

export default function ItemsPage() {
  const navigation = useNavigation<any>();

  const [items, setItems] = useState<any[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);
  const [keyword, setKeyword] = useState("");

  const fetchItems = async (pageNumber = 1, refresh = false) => {
    try {
      setLoading(true);

      const res = keyword
        ? await searchItems(keyword, pageNumber)
        : await getItems(pageNumber);

      setTotalPages(res.data.total_pages);
      setItems((prev) =>
        refresh ? res.data.data : [...prev, ...res.data.data]
      );
    } catch (err) {
      console.log(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setPage(1);
    fetchItems(1, true);
  }, [keyword]);

  const loadMore = () => {
    if (loading || page >= totalPages) return;
    const next = page + 1;
    setPage(next);
    fetchItems(next);
  };

  const handleDelete = (id: number) => {
    Alert.alert("Hapus Item", "Yakin mau hapus item ini?", [
      { text: "Batal" },
      {
        text: "Hapus",
        style: "destructive",
        onPress: async () => {
          await deleteItem(id);
          setPage(1);
          fetchItems(1, true);
        },
      },
    ]);
  };

  return (
    <View style={{ flex: 1, padding: 16 }}>
      {/* HEADER */}
      <View
        style={{
          flexDirection: "row",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: 12,
        }}
      >
        <Text style={{ fontSize: 20, fontWeight: "bold" }}>Item List</Text>

        <TouchableOpacity
          onPress={() => navigation.navigate("ItemForm")}
          style={{
            backgroundColor: "#2563eb",
            paddingVertical: 8,
            paddingHorizontal: 14,
            borderRadius: 6,
          }}
        >
          <Text style={{ color: "#fff" }}>+ Add</Text>
        </TouchableOpacity>
      </View>

      {/* SEARCH */}
      <TextInput
        placeholder="Cari nama item..."
        value={keyword}
        onChangeText={setKeyword}
        style={{
          borderWidth: 1,
          borderRadius: 6,
          padding: 10,
          marginBottom: 12,
        }}
      />

      <FlatList
        data={items}
        keyExtractor={(item) => item.id.toString()}
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        refreshing={loading}
        onRefresh={() => {
          setPage(1);
          fetchItems(1, true);
        }}
        renderItem={({ item }) => (
          <View
            style={{
              flexDirection: "row",
              padding: 12,
              borderWidth: 1,
              borderRadius: 8,
              marginBottom: 10,
              alignItems: "center",
            }}
          >
            {/* IMAGE LEFT */}
            <Image
              source={{
                uri:
                  item.image_url ||
                  "https://via.placeholder.com/100x100?text=No+Image",
              }}
              style={{
                width: 80,
                height: 80,
                borderRadius: 6,
                marginRight: 12,
                backgroundColor: "#e5e7eb",
              }}
              resizeMode="cover"
            />

            {/* CONTENT RIGHT */}
            <View style={{ flex: 1 }}>
              <Text style={{ fontWeight: "bold", fontSize: 16 }}>
                {item.name}
              </Text>
              <Text>SKU: {item.description}</Text>
              <Text>Stock: {item.stock}</Text>
              <Text>Buy Price: {item.buy_price}</Text>
              <Text>Price: {item.price}</Text>

              {/* ACTIONS */}
              <View style={{ flexDirection: "row", marginTop: 6 }}>
                <TouchableOpacity
                  onPress={() => navigation.navigate("ItemForm", { item })}
                  style={{ marginRight: 16 }}
                >
                  <Text style={{ color: "#2563eb" }}>Edit</Text>
                </TouchableOpacity>

                <TouchableOpacity onPress={() => handleDelete(item.id)}>
                  <Text style={{ color: "red" }}>Delete</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        )}
      />
    </View>
  );
}

import { useEffect, useState } from "react";
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  TextInput,
  Alert,
  ActivityIndicator,
  ScrollView,
  StyleSheet,
} from "react-native";
import { getItems, searchItems } from "../../services/items.service";
import { createTransaction } from "../../services/transaction.service";
import { printReceipt } from "../../utils/print";

const PAYMENT_TYPES = ["cash", "qris", "debit", "credit"];

export default function TransactionPage() {
  // ===== ITEM LIST =====
  const [items, setItems] = useState<any[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loadingItems, setLoadingItems] = useState(false);
  const [keyword, setKeyword] = useState("");

  // ===== CART =====
  const [cart, setCart] = useState<any[]>([]);
  const [discount, setDiscount] = useState(0);
  const [paymentAmount, setPaymentAmount] = useState(0);
  const [paymentType, setPaymentType] = useState("cash");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    resetAndFetch();
  }, [keyword]);

  const resetAndFetch = () => {
    setItems([]);
    setPage(1);
    fetchItems(1, true);
  };

  const fetchItems = async (pageNumber: number, reset = false) => {
    if (loadingItems || pageNumber > totalPages) return;

    try {
      setLoadingItems(true);
      const res = keyword
        ? await searchItems(keyword, pageNumber)
        : await getItems(pageNumber);

      setItems((prev) => (reset ? res.data.data : [...prev, ...res.data.data]));
      setPage(res.data.page);
      setTotalPages(res.data.total_pages);
    } catch (err) {
      console.log(err);
    } finally {
      setLoadingItems(false);
    }
  };

  // ===== CART LOGIC =====
  const addToCart = (item: any) => {
    const exist = cart.find((c) => c.id === item.id);
    if (exist) {
      setCart(
        cart.map((c) =>
          c.id === item.id ? { ...c, quantity: c.quantity + 1 } : c,
        ),
      );
    } else {
      setCart([
        ...cart,
        {
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: 1,
          customPrice: undefined,
        },
      ]);
    }
  };

  const updateQty = (id: number, qty: number) => {
    if (qty <= 0) return;
    setCart(cart.map((c) => (c.id === id ? { ...c, quantity: qty } : c)));
  };

  const updateCustomPrice = (id: number, price?: number) => {
    setCart(cart.map((c) => (c.id === id ? { ...c, customPrice: price } : c)));
  };

  const removeFromCart = (id: number) => {
    setCart(cart.filter((c) => c.id !== id));
  };

  // ===== ESTIMATION =====
  const estimatedTotal = cart.reduce((sum, i) => {
    const price = i.customPrice ?? i.price;
    return sum + price * i.quantity;
  }, 0);

  const finalEstimate = Math.max(estimatedTotal - discount, 0);

  // ===== SUBMIT =====
  const submitTransaction = async () => {
    if (cart.length === 0) {
      Alert.alert("Cart kosong");
      return;
    }

    try {
      setSubmitting(true);
      await createTransaction({
        status: "completed",
        discount: discount > 0 ? discount : undefined,
        paymentAmount,
        paymentType,
        items: cart.map((i) => ({
          item_id: i.id,
          quantity: i.quantity,
          customPrice: i.customPrice,
        })),
      });

      Alert.alert(
        "Success",
        "Transaction created. Do you want to print the receipt?",
        [
          { text: "No", style: "cancel" },
          {
            text: "Yes",
            onPress: () =>
              printReceipt({
                id: "NEW", // The API might not return the full ID immediately, so we just use NEW or we let it use the data we have.
                created_at: new Date().toISOString(),
                status: "completed",
                paymentAmount,
                paymentType,
                discount,
                total: finalEstimate,
                items: cart,
              }),
          },
        ],
      );
      setCart([]);
      setDiscount(0);
      setPaymentAmount(0);
      setPaymentType("cash");
    } catch (err: any) {
      Alert.alert(
        "Error",
        err.response?.data?.error || "Failed to create transaction",
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.pageTitle}>Create Transaction</Text>

      {/* SEARCH */}
      <TextInput
        placeholder="Cari nama item..."
        value={keyword}
        onChangeText={setKeyword}
        style={styles.search}
      />

      {/* ITEM LIST */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Item List</Text>

        <FlatList
          data={items}
          keyExtractor={(item) => item.id.toString()}
          onEndReached={() => fetchItems(page + 1)}
          onEndReachedThreshold={0.5}
          ListFooterComponent={
            loadingItems ? <ActivityIndicator style={{ margin: 12 }} /> : null
          }
          renderItem={({ item }) => (
            <TouchableOpacity
              onPress={() => addToCart(item)}
              style={styles.itemCard}
            >
              <View>
                <Text style={styles.itemName}>{item.name}</Text>
                <Text style={styles.muted}>Stock: {item.stock}</Text>
              </View>
              <Text style={styles.price}>Rp {item.price}</Text>
            </TouchableOpacity>
          )}
        />
      </View>

      {/* CART */}
      <View style={styles.cartSection}>
        <Text style={styles.sectionTitle}>Cart</Text>

        <ScrollView>
          {cart.length === 0 && (
            <Text style={styles.empty}>Cart masih kosong</Text>
          )}

          {cart.map((c) => (
            <View key={c.id} style={styles.cartCard}>
              <Text style={styles.itemName}>{c.name}</Text>

              <View style={styles.row}>
                <TextInput
                  keyboardType="numeric"
                  value={String(c.quantity)}
                  onChangeText={(v) => updateQty(c.id, Number(v))}
                  style={styles.inputSmall}
                  placeholder="Qty"
                />

                <TextInput
                  keyboardType="numeric"
                  placeholder="Custom price"
                  onChangeText={(v) =>
                    updateCustomPrice(c.id, v === "" ? undefined : Number(v))
                  }
                  style={styles.inputSmall}
                />
              </View>

              <TouchableOpacity onPress={() => removeFromCart(c.id)}>
                <Text style={styles.remove}>Remove</Text>
              </TouchableOpacity>
            </View>
          ))}

          {/* PAYMENT */}
          <View style={styles.paymentBox}>
            <Text>Estimated Total: Rp {estimatedTotal}</Text>

            <TextInput
              keyboardType="numeric"
              placeholder="Discount"
              value={discount ? String(discount) : ""}
              onChangeText={(v) => setDiscount(Number(v) || 0)}
              style={styles.input}
            />

            <Text style={styles.total}>Final: Rp {finalEstimate}</Text>

            <TextInput
              keyboardType="numeric"
              placeholder="Payment Amount"
              value={paymentAmount ? String(paymentAmount) : ""}
              onChangeText={(v) => setPaymentAmount(Number(v) || 0)}
              style={styles.input}
            />

            <Text style={styles.bold}>Payment Type</Text>

            <View style={styles.paymentTypes}>
              {PAYMENT_TYPES.map((type) => (
                <TouchableOpacity
                  key={type}
                  onPress={() => setPaymentType(type)}
                  style={[
                    styles.payBtn,
                    paymentType === type && styles.payBtnActive,
                  ]}
                >
                  <Text
                    style={{
                      color: paymentType === type ? "#fff" : "#000",
                    }}
                  >
                    {type.toUpperCase()}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <TouchableOpacity
              disabled={submitting}
              onPress={submitTransaction}
              style={styles.submit}
            >
              <Text style={styles.submitText}>
                {submitting ? "Processing..." : "Submit Transaction"}
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 12,
    backgroundColor: "#f1f5f9",
  },
  pageTitle: {
    fontSize: 20,
    fontWeight: "bold",
    marginBottom: 8,
  },
  search: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 10,
    backgroundColor: "#fff",
    marginBottom: 10,
  },
  section: {
    flex: 1,
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 10,
    marginBottom: 10,
  },
  cartSection: {
    flex: 1,
    backgroundColor: "#e5e7eb",
    borderRadius: 10,
    padding: 10,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 6,
  },
  itemCard: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    flexDirection: "row",
    justifyContent: "space-between",
    backgroundColor: "#fff",
  },
  itemName: {
    fontWeight: "bold",
  },
  price: {
    fontWeight: "bold",
  },
  muted: {
    color: "#64748b",
  },
  cartCard: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 10,
    marginBottom: 8,
    backgroundColor: "#fff",
  },
  row: {
    flexDirection: "row",
    gap: 8,
    marginTop: 6,
  },
  input: {
    borderWidth: 1,
    borderRadius: 6,
    padding: 8,
    marginTop: 6,
    backgroundColor: "#fff",
  },
  inputSmall: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 6,
    padding: 6,
    backgroundColor: "#fff",
  },
  paymentBox: {
    marginTop: 10,
    paddingTop: 8,
    borderTopWidth: 1,
  },
  paymentTypes: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginTop: 6,
  },
  payBtn: {
    borderWidth: 1,
    borderRadius: 6,
    paddingVertical: 8,
    paddingHorizontal: 12,
    marginRight: 6,
    marginTop: 6,
  },
  payBtnActive: {
    backgroundColor: "#2563eb",
  },
  submit: {
    backgroundColor: "#2563eb",
    padding: 14,
    borderRadius: 8,
    marginTop: 12,
  },
  submitText: {
    color: "#fff",
    textAlign: "center",
    fontWeight: "bold",
  },
  total: {
    fontSize: 16,
    fontWeight: "bold",
    marginTop: 6,
  },
  bold: {
    fontWeight: "bold",
    marginTop: 8,
  },
  remove: {
    color: "red",
    marginTop: 6,
  },
  empty: {
    color: "#6b7280",
    fontStyle: "italic",
  },
});

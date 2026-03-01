import { useEffect, useState } from "react";
import ItemList from "../components/transactions/ItemList";
import Cart from "../components/transactions/Cart";
import DraftModal from "../components/transactions/DraftModal";
import ReceiptModal from "../components/transactions/ReceiptModal";
import toast from "react-hot-toast";
import { useBluetoothPrinter } from "../context/BluetoothPrinterContext";

import {
  getItems,
  getDraftTransactions,
  createTransaction,
  getTransactionById,
} from "../services/transactionService";

export default function Transactions() {
  const [items, setItems] = useState([]);
  const [cart, setCart] = useState([]);
  const [paymentAmount, setPaymentAmount] = useState(0);
  const [paymentType, setPaymentType] = useState("cash");
  const [transactionType, setTransactionType] = useState("onsite");
  const [drafts, setDrafts] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [receipt, setReceipt] = useState(null);
  const [isReceiptOpen, setIsReceiptOpen] = useState(false);
  const [note, setNote] = useState("");
  const [discount, setDiscount] = useState(0);

  // 🔥 dari context
  const {
    device,
    isConnecting,
    connectPrinter,
    disconnectPrinter,
    printReceipt,
  } = useBluetoothPrinter();

  useEffect(() => {
    getItems()
      .then((data) => setItems(Array.isArray(data) ? data : []))
      .catch(() => toast.error("Gagal mengambil items"));

    fetchDrafts();
  }, []);

  const fetchDrafts = () => {
    getDraftTransactions()
      .then(setDrafts)
      .catch(() => toast.error("Gagal mengambil draft"));
  };

  const addToCart = (item) => {
    setCart((prev) => {
      const exist = prev.find((c) => c.item_id === item.id);
      if (exist) {
        return prev.map((c) =>
          c.item_id === item.id ? { ...c, quantity: c.quantity + 1 } : c,
        );
      }
      return [
        ...prev,
        { item_id: item.id, name: item.name, price: item.price, quantity: 1 },
      ];
    });
  };

  const updateQuantity = (itemId, quantity, price) => {
    setCart((prev) =>
      prev.map((c) =>
        c.item_id === itemId
          ? { ...c, quantity: quantity ?? c.quantity, price: price ?? c.price }
          : c,
      ),
    );
  };

  const removeFromCart = (itemId) => {
    setCart((prev) => prev.filter((c) => c.item_id !== itemId));
  };

  const totalBeforeDiscount = cart.reduce(
    (acc, c) => acc + c.price * c.quantity,
    0,
  );
  const total = Math.max(totalBeforeDiscount - discount, 0);
  const change = paymentAmount - total;

  const handleCheckout = async (checkoutStatus) => {
    if (checkoutStatus === "completed" && change < 0) {
      toast.error("Uang bayar kurang");
      return;
    }

    const payload = {
      status: checkoutStatus,
      paymentAmount: checkoutStatus === "completed" ? paymentAmount : undefined,
      paymentType: checkoutStatus === "completed" ? paymentType : undefined,
      note: note || undefined,
      transaction_type: transactionType,
      discount: parseFloat(discount) || 0,
      items: cart.map((c) => ({
        item_id: c.item_id,
        quantity: c.quantity,
        customPrice: c.price,
      })),
    };

    try {
      const res = await createTransaction(payload);

      setCart([]);
      setPaymentAmount(0);
      setPaymentType("cash");
      setTransactionType("onsite");
      setNote("");
      setDiscount(0);
      fetchDrafts();

      if (checkoutStatus === "completed") {
        setReceipt(res.transaction || res);
        setIsReceiptOpen(true);
        toast.success("Transaksi berhasil");
      } else {
        toast.success("Draft disimpan");
      }
    } catch (err) {
      console.error(err);
      toast.error("Gagal submit transaksi");
    }
  };

  const loadDraft = async (transactionId) => {
    try {
      const t = await getTransactionById(transactionId);
      setCart(
        t.items.map((i) => ({
          item_id: i.item_id,
          name: i.item.name,
          price: i.price,
          quantity: i.quantity,
        })),
      );
      setPaymentAmount(t.payment || 0);
      setPaymentType(t.paymentType || "cash");
      setTransactionType(t.transaction_type || "onsite");
      setNote(t.note || "");
      setDiscount(t.discount || 0);
      setIsModalOpen(false);

      toast("Draft dimuat");
    } catch {
      toast.error("Gagal memuat draft");
    }
  };

  return (
    <div className="flex flex-col md:flex-row gap-4 w-full min-h-screen bg-gray-100 p-2 md:p-4">
      <ItemList items={items} addToCart={addToCart} />

      <Cart
        cart={cart}
        updateQuantity={updateQuantity}
        removeFromCart={removeFromCart}
        total={total}
        paymentAmount={paymentAmount}
        setPaymentAmount={setPaymentAmount}
        paymentType={paymentType}
        setPaymentType={setPaymentType}
        transactionType={transactionType}
        setTransactionType={setTransactionType}
        handleCheckout={handleCheckout}
        change={change}
        note={note}
        setNote={setNote}
        discount={discount}
        setDiscount={setDiscount}
        openModal={() => setIsModalOpen(true)}
        device={device}
        isConnecting={isConnecting}
        connectPrinter={connectPrinter}
        disconnectPrinter={disconnectPrinter}
        printReceipt={printReceipt}
      />

      <DraftModal
        drafts={drafts}
        isOpen={isModalOpen}
        closeModal={() => setIsModalOpen(false)}
        loadDraft={loadDraft}
      />

      <ReceiptModal
        isOpen={isReceiptOpen}
        onClose={() => setIsReceiptOpen(false)}
        transaction={receipt}
      />
    </div>
  );
}

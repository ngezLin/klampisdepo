import { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { Skeleton } from "@mui/material";
import {
  CalendarClock,
  Plus,
  Search,
  Upload,
  Calendar,
  AlertCircle,
  CheckCircle2,
  Clock,
  Trash2,
  FileText,
  TrendingUp,
  Image as ImageIcon,
  Check,
  RefreshCw,
} from "lucide-react";
import {
  getPOBills,
  createPOBill,
  markAsPaid,
  deletePOBill,
  uploadReceipt,
} from "../services/poBillService";
import { BASE_URL } from "../services/api";
import { formatCurrency } from "../utils/format";
import Button from "../components/common/Button";
import Card from "../components/common/Card";
import StatCard from "../components/common/StatCard";
import Modal from "../components/common/Modal";
import Input from "../components/common/Input";
import ConfirmDialog from "../components/common/ConfirmDialog";

export default function POBills() {
  const [bills, setBills] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("pending"); // "pending" | "paid"
  const [searchTerm, setSearchTerm] = useState("");
  const [sortBy, setSortBy] = useState("due_date_asc");

  // Modals state
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isViewerOpen, setIsViewerOpen] = useState(false);
  const [selectedReceiptUrl, setSelectedReceiptUrl] = useState("");
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [billToDelete, setBillToDelete] = useState(null);

  // Form state
  const [formValues, setFormValues] = useState({
    invoice_number: "",
    vendor_name: "",
    amount: "",
    received_date: new Date().toISOString().split("T")[0],
    due_date_type: "terms", // "terms" | "custom"
    payment_terms: "30", // "30" | "45" | "60" | "90" | "custom"
    custom_terms_days: "",
    custom_due_date: "",
    receipt_image: "",
    notes: "",
  });
  const [isUploading, setIsUploading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Fetch PO Bills
  const fetchBills = async () => {
    setLoading(true);
    try {
      const data = await getPOBills("", ""); // Fetch all, we will filter in frontend or backend
      setBills(data || []);
    } catch (err) {
      console.error(err);
      toast.error("Gagal mengambil data tagihan PO");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBills();
  }, []);

  // Calculate Due Date based on form values
  const getCalculatedDueDate = () => {
    const { received_date, due_date_type, payment_terms, custom_terms_days, custom_due_date } = formValues;
    if (!received_date) return "";

    if (due_date_type === "custom") {
      return custom_due_date || "";
    }

    let daysToAdd = 30;
    if (payment_terms === "custom") {
      daysToAdd = parseInt(custom_terms_days) || 0;
    } else {
      daysToAdd = parseInt(payment_terms) || 30;
    }

    const recDate = new Date(received_date);
    recDate.setDate(recDate.getDate() + daysToAdd);
    return recDate.toISOString().split("T")[0];
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormValues((prev) => ({ ...prev, [name]: value }));
  };

  const handleUploadImage = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (file.size > 5 * 1024 * 1024) {
      toast.error("Ukuran file terlalu besar (Maksimal 5MB)");
      return;
    }

    setIsUploading(true);
    try {
      const res = await uploadReceipt(file);
      setFormValues((prev) => ({ ...prev, receipt_image: res.url }));
      toast.success("Foto nota berhasil diunggah!");
    } catch (err) {
      console.error(err);
      toast.error("Gagal mengunggah foto nota");
    } finally {
      setIsUploading(false);
    }
  };

  const handleFormSubmit = async (e) => {
    e.preventDefault();
    const calculatedDueDate = getCalculatedDueDate();

    if (!calculatedDueDate) {
      toast.error("Harap tentukan tanggal jatuh tempo.");
      return;
    }

    setIsSubmitting(true);
    try {
      const payload = {
        invoice_number: formValues.invoice_number,
        vendor_name: formValues.vendor_name,
        amount: parseFloat(formValues.amount),
        received_date: formValues.received_date,
        due_date: calculatedDueDate,
        receipt_image: formValues.receipt_image,
        notes: formValues.notes,
      };

      await createPOBill(payload);
      toast.success("Tagihan PO berhasil ditambahkan!");
      setIsCreateOpen(false);
      // Reset form
      setFormValues({
        invoice_number: "",
        vendor_name: "",
        amount: "",
        received_date: new Date().toISOString().split("T")[0],
        due_date_type: "terms",
        payment_terms: "30",
        custom_terms_days: "",
        custom_due_date: "",
        receipt_image: "",
        notes: "",
      });
      fetchBills();
    } catch (err) {
      console.error(err);
      toast.error(err.response?.data?.error || "Gagal menyimpan tagihan PO");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleMarkAsPaid = async (id) => {
    try {
      await markAsPaid(id);
      toast.success("Tagihan PO berhasil ditandai LUNAS!");
      fetchBills();
    } catch (err) {
      console.error(err);
      toast.error("Gagal menandai lunas");
    }
  };

  const handleDeleteConfirm = async () => {
    if (!billToDelete) return;
    try {
      await deletePOBill(billToDelete.id);
      toast.success("Tagihan PO berhasil dihapus");
      setIsDeleteOpen(false);
      setBillToDelete(null);
      fetchBills();
    } catch (err) {
      console.error(err);
      toast.error("Gagal menghapus tagihan PO");
    }
  };

  // Date Logic for Countdown badges
  const getCountdownInfo = (dueDateStr) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const dueDate = new Date(dueDateStr);
    dueDate.setHours(0, 0, 0, 0);

    const diffTime = dueDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return {
        label: `Terlambat ${Math.abs(diffDays)} hari`,
        colorClass: "bg-rose-500/10 text-rose-500 border border-rose-500/20",
        isUrgent: true,
      };
    } else if (diffDays === 0) {
      return {
        label: "JATUH TEMPO HARI INI",
        colorClass: "bg-amber-500/20 text-amber-500 border border-amber-500/30 animate-pulse font-black",
        isUrgent: true,
      };
    } else if (diffDays === 1) {
      return {
        label: "Jatuh tempo besok",
        colorClass: "bg-amber-500/10 text-amber-400 border border-amber-500/20 font-bold",
        isUrgent: true,
      };
    } else if (diffDays <= 7) {
      return {
        label: `Sisa ${diffDays} hari`,
        colorClass: "bg-orange-500/10 text-orange-400 border border-orange-500/20",
        isUrgent: false,
      };
    } else {
      return {
        label: `Sisa ${diffDays} hari`,
        colorClass: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
        isUrgent: false,
      };
    }
  };

  // Filter & Sort Bills
  const filteredBills = bills
    .filter((bill) => {
      const matchStatus = bill.status === activeTab;
      const matchSearch =
        bill.vendor_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        bill.invoice_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (bill.notes && bill.notes.toLowerCase().includes(searchTerm.toLowerCase()));
      return matchStatus && matchSearch;
    })
    .sort((a, b) => {
      if (sortBy === "due_date_asc") {
        return new Date(a.due_date) - new Date(b.due_date);
      } else if (sortBy === "due_date_desc") {
        return new Date(b.due_date) - new Date(a.due_date);
      } else if (sortBy === "received_date_desc") {
        return new Date(b.received_date) - new Date(a.received_date);
      } else if (sortBy === "amount_desc") {
        return b.amount - a.amount;
      } else if (sortBy === "amount_asc") {
        return a.amount - b.amount;
      }
      return 0;
    });

  // Calculate Statistics
  const unpaidBills = bills.filter((b) => b.status === "pending");
  const paidBills = bills.filter((b) => b.status === "paid");

  const totalOutstanding = unpaidBills.reduce((sum, b) => sum + b.amount, 0);

  const overdueCount = unpaidBills.filter((b) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return new Date(b.due_date) < today;
  }).length;

  const dueSoonCount = unpaidBills.filter((b) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const due = new Date(b.due_date);
    const diffTime = due.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays >= 0 && diffDays <= 7;
  }).length;

  const formatDate = (dateStr) => {
    if (!dateStr) return "-";
    const date = new Date(dateStr);
    return date.toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
  };

  if (loading && bills.length === 0) {
    return (
      <div className="p-4 sm:p-6 lg:p-10 space-y-10 min-h-screen">
        <div className="flex flex-col gap-2">
          <Skeleton variant="text" width={280} height={48} sx={{ bgcolor: "rgba(255,255,255,0.03)" }} />
          <Skeleton variant="text" width={380} height={24} sx={{ bgcolor: "rgba(255,255,255,0.03)" }} />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Skeleton variant="rounded" height={130} sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }} />
          <Skeleton variant="rounded" height={130} sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }} />
          <Skeleton variant="rounded" height={130} sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }} />
        </div>
        <Skeleton variant="rounded" height={400} sx={{ bgcolor: "rgba(255,255,255,0.03)", borderRadius: "24px" }} />
      </div>
    );
  }

  return (
    <div className="p-4 sm:p-6 lg:p-10 min-h-screen max-w-7xl mx-auto overflow-hidden">
      {/* Header */}
      <div className="mb-12 flex flex-col md:flex-row md:items-end md:justify-between gap-6">
        <div>
          <div className="flex items-center gap-4 mb-2">
            <div className="p-2.5 rounded-xl bg-blue-600/10 border border-blue-500/20">
              <CalendarClock className="w-8 h-8 text-blue-500" />
            </div>
            <h1 className="text-4xl font-black text-white tracking-tight">
              Tagihan PO
            </h1>
          </div>
          <p className="text-slate-500 font-medium italic">
            Kelola pembayaran produk Purchase Order, pantau sisa hari jatuh tempo, dan simpan foto nota.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Button
            variant="primary"
            size="md"
            icon={Plus}
            onClick={() => setIsCreateOpen(true)}
            className="shadow-lg shadow-blue-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all duration-200"
          >
            Tambah Tagihan Baru
          </Button>
        </div>
      </div>

      {/* Summary Statistics */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
        <StatCard
          label="Total Belum Dibayar"
          value={formatCurrency(totalOutstanding)}
          icon={TrendingUp}
          colorClass="text-rose-400"
          className={totalOutstanding > 0 ? "border-rose-500/10 bg-rose-500/[0.01]" : ""}
        />
        <StatCard
          label="Terlambat (Overdue)"
          value={`${overdueCount} Tagihan`}
          icon={AlertCircle}
          colorClass="text-rose-500"
          className={overdueCount > 0 ? "border-rose-500/30 bg-rose-500/5 shadow-[0_0_20px_rgba(244,63,94,0.05)] animate-pulse" : ""}
        />
        <StatCard
          label="Jatuh Tempo 7 Hari Ke Depan"
          value={`${dueSoonCount} Tagihan`}
          icon={Clock}
          colorClass="text-amber-400"
          className={dueSoonCount > 0 ? "border-amber-500/20 bg-amber-500/[0.02]" : ""}
        />
      </div>

      {/* Main Card View */}
      <Card className="border border-white/5 bg-slate-950/20 backdrop-blur-2xl">
        {/* Toolbar & Filters */}
        <div className="flex flex-col lg:flex-row gap-4 items-center justify-between pb-6 mb-6 border-b border-white/5">
          {/* Tabs */}
          <div className="flex bg-slate-900/50 p-1.5 rounded-xl border border-white/5 w-full lg:w-auto">
            <button
              onClick={() => setActiveTab("pending")}
              className={`flex-1 lg:flex-initial flex items-center justify-center gap-2 px-6 py-2.5 rounded-lg text-xs font-bold uppercase tracking-wider transition-all duration-300 ${
                activeTab === "pending"
                  ? "bg-blue-600 text-white shadow-lg shadow-blue-600/20 font-black"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              <Clock className="w-4 h-4" />
              Belum Lunas ({unpaidBills.length})
            </button>
            <button
              onClick={() => setActiveTab("paid")}
              className={`flex-1 lg:flex-initial flex items-center justify-center gap-2 px-6 py-2.5 rounded-lg text-xs font-bold uppercase tracking-wider transition-all duration-300 ${
                activeTab === "paid"
                  ? "bg-emerald-600 text-white shadow-lg shadow-emerald-600/20 font-black"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              <CheckCircle2 className="w-4 h-4" />
              Lunas ({paidBills.length})
            </button>
          </div>

          {/* Search and Sort */}
          <div className="flex flex-col sm:flex-row gap-4 w-full lg:w-auto items-stretch">
            {/* Search Input */}
            <div className="relative flex-1 sm:w-64">
              <span className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-4 w-4 text-slate-500" />
              </span>
              <input
                type="text"
                placeholder="Cari vendor, invoice..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-9 pr-4 py-2.5 rounded-xl bg-slate-900/50 border border-white/5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all"
              />
            </div>

            {/* Sort Select */}
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="bg-slate-900/50 border border-white/5 text-slate-300 text-sm py-2 px-4 rounded-xl focus:outline-none focus:border-blue-500 transition-all font-medium"
            >
              <option value="due_date_asc">Tempo Terdekat</option>
              <option value="due_date_desc">Tempo Terjauh</option>
              <option value="received_date_desc">Tanggal Terima (Baru)</option>
              <option value="amount_desc">Tagihan Terbesar</option>
              <option value="amount_asc">Tagihan Terkecil</option>
            </select>
          </div>
        </div>

        {/* Table / List Container */}
        {filteredBills.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500 space-y-4">
            <div className="p-4 rounded-full bg-slate-900 border border-white/5">
              <FileText className="w-12 h-12 opacity-20" />
            </div>
            <div className="text-center">
              <p className="text-base font-bold text-slate-400">Tidak ada data tagihan</p>
              <p className="text-xs text-slate-600 mt-1">
                {searchTerm ? "Coba ganti kata kunci pencarian Anda." : "Klik tombol 'Tambah Tagihan Baru' untuk mulai."}
              </p>
            </div>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-left">
              <thead>
                <tr className="border-b border-white/5 text-slate-500 text-[10px] font-black uppercase tracking-widest">
                  <th className="pb-4 pl-4">Vendor & Invoice</th>
                  <th className="pb-4">Nominal</th>
                  <th className="pb-4">Tanggal Terima</th>
                  <th className="pb-4">Batas Pembayaran</th>
                  <th className="pb-4 text-center">Nota</th>
                  <th className="pb-4">Countdown / Status</th>
                  <th className="pb-4 pr-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/[0.02] text-sm font-semibold text-slate-300">
                {filteredBills.map((bill) => {
                  const countdown = getCountdownInfo(bill.due_date);
                  return (
                    <tr key={bill.id} className="group hover:bg-white/[0.01] transition-colors">
                      <td className="py-4 pl-4">
                        <div className="flex flex-col">
                          <span className="font-bold text-white text-base group-hover:text-blue-400 transition-colors">
                            {bill.vendor_name}
                          </span>
                          <span className="text-xs text-slate-500 mt-0.5 font-medium">
                            {bill.invoice_number}
                          </span>
                        </div>
                      </td>
                      <td className="py-4 font-bold text-white">
                        {formatCurrency(bill.amount)}
                      </td>
                      <td className="py-4 text-slate-400 font-medium">
                        {formatDate(bill.received_date)}
                      </td>
                      <td className="py-4 text-slate-400 font-medium">
                        {formatDate(bill.due_date)}
                      </td>
                      <td className="py-4 text-center">
                        {bill.receipt_image ? (
                          <button
                            onClick={() => {
                              setSelectedReceiptUrl(bill.receipt_image);
                              setIsViewerOpen(true);
                            }}
                            className="p-2 rounded-lg bg-white/5 border border-white/10 hover:bg-blue-600/10 hover:text-blue-400 hover:border-blue-500/20 transition-all duration-200"
                            title="Lihat Foto Nota"
                          >
                            <ImageIcon className="w-4 h-4" />
                          </button>
                        ) : (
                          <span className="text-slate-600 text-xs italic font-medium">Tidak ada</span>
                        )}
                      </td>
                      <td className="py-4">
                        {bill.status === "paid" ? (
                          <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs font-bold uppercase tracking-wider">
                            <Check className="w-3.5 h-3.5" />
                            Lunas ({formatDate(bill.paid_date)})
                          </div>
                        ) : (
                          <div className={`inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider ${countdown.colorClass}`}>
                            {countdown.isUrgent && <AlertCircle className="w-3.5 h-3.5 mr-1.5 flex-shrink-0" />}
                            {countdown.label}
                          </div>
                        )}
                      </td>
                      <td className="py-4 pr-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          {bill.status === "pending" && (
                            <button
                              onClick={() => handleMarkAsPaid(bill.id)}
                              className="px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold transition-all shadow-md shadow-emerald-600/10 hover:scale-[1.02] active:scale-[0.98]"
                            >
                              Tandai Lunas
                            </button>
                          )}
                          <button
                            onClick={() => {
                              setBillToDelete(bill);
                              setIsDeleteOpen(true);
                            }}
                            className="p-2 rounded-lg text-slate-500 hover:text-rose-500 hover:bg-rose-500/10 transition-colors"
                            title="Hapus Tagihan"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* CREATE MODAL */}
      <Modal
        isOpen={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
        title="Tambah Tagihan PO Baru"
        maxWidth="max-w-xl"
      >
        <form onSubmit={handleFormSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              label="Nama Vendor / Supplier"
              name="vendor_name"
              placeholder="e.g. PT Sinar Abadi"
              value={formValues.vendor_name}
              onChange={handleInputChange}
              required
            />
            <Input
              label="Nomor Invoice / PO"
              name="invoice_number"
              placeholder="e.g. INV/2026/06/001"
              value={formValues.invoice_number}
              onChange={handleInputChange}
              required
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              label="Nominal Tagihan (Rupiah)"
              name="amount"
              type="number"
              placeholder="e.g. 5000000"
              value={formValues.amount}
              onChange={handleInputChange}
              required
            />
            <Input
              label="Tanggal Barang Diterima"
              name="received_date"
              type="date"
              value={formValues.received_date}
              onChange={handleInputChange}
              required
            />
          </div>

          {/* Payment Terms Calculator */}
          <div className="space-y-3 bg-slate-900/50 p-4 rounded-xl border border-white/5">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Batas Jatuh Tempo Pembayaran
            </label>
            
            <div className="flex gap-4 mb-2">
              <label className="flex items-center gap-2 text-xs font-semibold text-slate-300 cursor-pointer">
                <input
                  type="radio"
                  name="due_date_type"
                  value="terms"
                  checked={formValues.due_date_type === "terms"}
                  onChange={handleInputChange}
                  className="text-blue-500 focus:ring-0 focus:ring-offset-0 bg-slate-950 border-white/10"
                />
                Hitung dari Tenor (+Hari)
              </label>
              <label className="flex items-center gap-2 text-xs font-semibold text-slate-300 cursor-pointer">
                <input
                  type="radio"
                  name="due_date_type"
                  value="custom"
                  checked={formValues.due_date_type === "custom"}
                  onChange={handleInputChange}
                  className="text-blue-500 focus:ring-0 focus:ring-offset-0 bg-slate-950 border-white/10"
                />
                Pilih Tanggal Manual
              </label>
            </div>

            {formValues.due_date_type === "terms" ? (
              <div className="space-y-3">
                <div className="flex flex-wrap gap-2">
                  {["30", "45", "60", "90"].map((days) => (
                    <button
                      key={days}
                      type="button"
                      onClick={() => setFormValues((prev) => ({ ...prev, payment_terms: days }))}
                      className={`px-4 py-2 rounded-lg text-xs font-bold border transition-all duration-200 ${
                        formValues.payment_terms === days
                          ? "bg-blue-600/20 text-blue-400 border-blue-500/40"
                          : "bg-slate-950/40 text-slate-400 border-white/5 hover:text-white"
                      }`}
                    >
                      +{days} Hari
                    </button>
                  ))}
                  <button
                    type="button"
                    onClick={() => setFormValues((prev) => ({ ...prev, payment_terms: "custom" }))}
                    className={`px-4 py-2 rounded-lg text-xs font-bold border transition-all duration-200 ${
                      formValues.payment_terms === "custom"
                        ? "bg-blue-600/20 text-blue-400 border-blue-500/40"
                        : "bg-slate-950/40 text-slate-400 border-white/5 hover:text-white"
                    }`}
                  >
                    Custom
                  </button>
                </div>

                {formValues.payment_terms === "custom" && (
                  <Input
                    label="Jumlah Hari Tenor"
                    name="custom_terms_days"
                    type="number"
                    placeholder="Contoh: 15, 50, 120"
                    value={formValues.custom_terms_days}
                    onChange={handleInputChange}
                    required
                  />
                )}
              </div>
            ) : (
              <Input
                label="Tanggal Jatuh Tempo"
                name="custom_due_date"
                type="date"
                value={formValues.custom_due_date}
                onChange={handleInputChange}
                required
              />
            )}

            {/* Live Calculated Due Date Output Preview */}
            <div className="pt-2 flex items-center justify-between text-xs border-t border-white/5 font-semibold">
              <span className="text-slate-500">Estimasi Jatuh Tempo:</span>
              <span className="text-blue-400 text-sm font-bold flex items-center gap-1">
                <Calendar className="w-4 h-4" />
                {formatDate(getCalculatedDueDate()) || "Belum ditentukan"}
              </span>
            </div>
          </div>

          {/* Receipt Image Upload */}
          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Foto Nota / Tanda Terima (Opsional)
            </label>
            {formValues.receipt_image ? (
              <div className="relative group rounded-xl overflow-hidden border border-white/10 aspect-video max-h-48">
                <img
                  src={`${BASE_URL || ""}${formValues.receipt_image}`}
                  alt="Receipt Preview"
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-black/60 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <button
                    type="button"
                    onClick={() => setFormValues((prev) => ({ ...prev, receipt_image: "" }))}
                    className="px-4 py-2 bg-rose-600 hover:bg-rose-500 text-white rounded-lg text-xs font-bold transition-colors"
                  >
                    Hapus
                  </button>
                </div>
              </div>
            ) : (
              <label className="flex flex-col items-center justify-center border-2 border-white/10 border-dashed rounded-xl p-8 hover:bg-white/[0.02] hover:border-white/20 transition-all cursor-pointer">
                {isUploading ? (
                  <div className="flex flex-col items-center gap-2">
                    <RefreshCw className="w-8 h-8 text-blue-500 animate-spin" />
                    <span className="text-xs font-semibold text-slate-400">Mengunggah file...</span>
                  </div>
                ) : (
                  <div className="flex flex-col items-center gap-2">
                    <Upload className="w-8 h-8 text-slate-500" />
                    <span className="text-xs font-bold text-slate-300">Pilih berkas foto nota</span>
                    <span className="text-[10px] text-slate-500 font-medium">JPEG, PNG, WEBP hingga 5MB</span>
                  </div>
                )}
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleUploadImage}
                  className="hidden"
                  disabled={isUploading}
                />
              </label>
            )}
          </div>

          {/* Notes */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Catatan Tambahan
            </label>
            <textarea
              name="notes"
              rows="3"
              placeholder="e.g. Produk PO Susu Bayi, bayar via transfer Mandiri"
              value={formValues.notes}
              onChange={handleInputChange}
              className="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all"
            />
          </div>

          <div className="flex gap-4 justify-end pt-4 border-t border-white/5">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setIsCreateOpen(false)}
              disabled={isSubmitting}
            >
              Batal
            </Button>
            <Button
              type="submit"
              variant="primary"
              disabled={isSubmitting || isUploading}
              className="px-6"
            >
              {isSubmitting ? "Menyimpan..." : "Simpan Tagihan"}
            </Button>
          </div>
        </form>
      </Modal>

      {/* LIGHTBOX VIEWER MODAL */}
      <Modal
        isOpen={isViewerOpen}
        onClose={() => setIsViewerOpen(false)}
        title="Foto Nota Penerimaan"
        maxWidth="max-w-3xl"
      >
        <div className="flex items-center justify-center p-2 bg-slate-950 rounded-xl border border-white/5 overflow-hidden">
          <img
            src={`${BASE_URL || ""}${selectedReceiptUrl}`}
            alt="Nota Tagihan PO"
            className="max-h-[70vh] object-contain rounded-lg shadow-2xl"
          />
        </div>
        <div className="mt-4 flex justify-end">
          <Button variant="secondary" onClick={() => setIsViewerOpen(false)}>
            Tutup
          </Button>
        </div>
      </Modal>

      {/* DELETE CONFIRM DIALOG */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={handleDeleteConfirm}
        title="Hapus Tagihan PO?"
        message={`Apakah Anda yakin ingin menghapus tagihan PO dari ${billToDelete?.vendor_name || "vendor ini"}? Tindakan ini tidak dapat dibatalkan.`}
        confirmText="Hapus Tagihan"
        cancelText="Batal"
      />
    </div>
  );
}

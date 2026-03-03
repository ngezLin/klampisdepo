import { useEffect, useState, useMemo } from "react";
import { formatCurrency } from "../utils/format";
import toast from "react-hot-toast";
import {
  getTransactionHistory,
  refundTransaction,
} from "../services/transactionService";
import ReceiptModal from "../components/transactions/ReceiptModal";
import ConfirmDialog from "../components/common/ConfirmDialog";
import StatusBadge from "../components/common/StatusBadge";
import {
  Calendar,
  Undo2,
  Eye,
  History as HistoryIcon,
  DollarSign,
  CheckCircle2,
} from "lucide-react";
import StatCard from "../components/common/StatCard";
import Card from "../components/common/Card";
import Button from "../components/common/Button";

// StatusBadge is now imported from shared components

export default function History() {
  const [transactions, setTransactions] = useState([]);
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [filterDate, setFilterDate] = useState(() => {
    const today = new Date().toISOString().split("T")[0];
    return today;
  });

  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const itemsPerPage = 10;
  const [loading, setLoading] = useState(false);
  const [refundTarget, setRefundTarget] = useState(null);

  // Stats calculation
  const stats = useMemo(() => {
    const totalRevenue = transactions.reduce(
      (acc, curr) => acc + (curr.status === "completed" ? curr.total : 0),
      0,
    );
    const completedCount = transactions.filter(
      (t) => t.status === "completed",
    ).length;
    const refundedCount = transactions.filter(
      (t) => t.status === "refunded",
    ).length;

    return {
      revenue: totalRevenue,
      completed: completedCount,
      refunded: refundedCount,
    };
  }, [transactions]);

  const fetchHistory = async (page = 1, date = "") => {
    try {
      setLoading(true);
      const res = await getTransactionHistory(page, itemsPerPage, date);
      const sortedData = res.data.sort(
        (a, b) => new Date(b.created_at) - new Date(a.created_at),
      );
      setTransactions(sortedData);
      setTotalPages(res.totalPages || res.total_pages || 1);
      setCurrentPage(res.page || 1);
    } catch (err) {
      console.error("Failed to fetch history:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory(currentPage, filterDate);
  }, [currentPage, filterDate]);

  const viewDetails = (trx) => {
    setSelectedTransaction(trx);
    setIsModalOpen(true);
  };

  const handleRefund = async (id) => {
    try {
      await refundTransaction(id);
      setRefundTarget(null);
      await fetchHistory(currentPage, filterDate);
      toast.success("Transaksi berhasil di-refund");
    } catch (err) {
      console.error("Refund failed:", err);
      toast.error("Gagal melakukan refund");
    }
  };

  const handleDateChange = (e) => {
    setFilterDate(e.target.value);
    setCurrentPage(1);
  };

  const clearFilter = () => {
    setFilterDate("");
    setCurrentPage(1);
  };

  const getPageNumbers = () => {
    const maxButtons = 5;
    let startPage = Math.max(currentPage - Math.floor(maxButtons / 2), 1);
    let endPage = startPage + maxButtons - 1;
    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = Math.max(endPage - maxButtons + 1, 1);
    }
    const pages = [];
    for (let i = startPage; i <= endPage; i++) {
      pages.push(i);
    }
    return pages;
  };

  return (
    <div className="p-4 sm:p-6 bg-[#0a0a0a] min-h-screen text-gray-100 max-w-7xl mx-auto animate-in fade-in duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-white tracking-tight flex items-center gap-3">
            <HistoryIcon className="text-blue-500 w-8 h-8" />
            Riwayat Transaksi
          </h1>
          <p className="text-gray-500 mt-1 font-medium italic">
            Lacak dan kelola semua transaksi penjualan Anda.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Calendar className="w-4 h-4 text-gray-500 group-focus-within:text-blue-500 transition-colors" />
            </div>
            <input
              type="date"
              value={filterDate}
              onChange={handleDateChange}
              className="bg-gray-900 border border-white/10 text-white pl-10 pr-3 py-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/50 transition-all hover:bg-gray-800"
            />
          </div>
          {filterDate && (
            <Button variant="ghost" onClick={clearFilter} className="h-[46px]">
              Semua Waktu
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <StatCard
          label="Omzet Halaman Ini"
          value={formatCurrency(stats.revenue)}
          icon={DollarSign}
          colorClass="text-green-400"
        />
        <StatCard
          label="Selesai"
          value={`${stats.completed} Trx`}
          icon={CheckCircle2}
          colorClass="text-blue-400"
        />
        <StatCard
          label="Refund"
          value={`${stats.refunded} Trx`}
          icon={Undo2}
          colorClass="text-red-400"
        />
      </div>

      {loading ? (
        <div className="flex flex-col items-center justify-center py-24 bg-white/5 rounded-3xl border border-white/5 border-dashed">
          <div className="w-10 h-10 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-gray-500 mt-4 font-medium italic">
            Mengambil data transaksi...
          </p>
        </div>
      ) : (
        <Card className="px-0 py-0 overflow-hidden border-white/10 shadow-2xl">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-white/5 text-gray-400 border-b border-white/5">
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    ID
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    Status
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    Total
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest">
                    Waktu
                  </th>
                  <th className="px-6 py-4 text-xs font-black uppercase tracking-widest text-right">
                    Aksi
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {transactions.map((trx) => {
                  const dateObj =
                    typeof trx.created_at === "number"
                      ? new Date(trx.created_at * 1000)
                      : new Date(trx.created_at);
                  const formattedDate = isNaN(dateObj.getTime())
                    ? "-"
                    : dateObj.toLocaleString("id-ID", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                        hour: "2-digit",
                        minute: "2-digit",
                      });
                  return (
                    <tr
                      key={trx.id}
                      className="hover:bg-white/5 transition-colors group"
                    >
                      <td className="px-6 py-4 font-mono text-xs text-gray-500 group-hover:text-blue-400 transition-colors">
                        #{trx.id}
                      </td>
                      <td className="px-6 py-4">
                        <StatusBadge status={trx.status} />
                      </td>
                      <td className="px-6 py-4">
                        <span className="font-bold text-white">
                          Rp {trx.total?.toLocaleString() || 0}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-400">
                        {formattedDate}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            title="Detail"
                            className="p-2 bg-blue-600/10 hover:bg-blue-600 text-blue-500 hover:text-white rounded-lg transition-all active:scale-90"
                            onClick={() => viewDetails(trx)}
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          {trx.status === "completed" && (
                            <button
                              title="Refund"
                              className="p-2 bg-red-600/10 hover:bg-red-600 text-red-500 hover:text-white rounded-lg transition-all active:scale-90"
                              onClick={() => setRefundTarget(trx.id)}
                            >
                              <Undo2 className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {transactions.length === 0 && (
            <div className="py-24 text-center">
              <HistoryIcon className="w-12 h-12 text-gray-800 mx-auto mb-4 opacity-20" />
              <p className="text-gray-500 font-medium italic">
                Tidak ada transaksi yang ditemukan
              </p>
            </div>
          )}

          {totalPages > 1 && (
            <div className="px-6 py-4 bg-white/5 border-t border-white/5 flex items-center justify-between">
              <span className="text-xs font-black text-gray-500 uppercase tracking-widest">
                Hal <span className="text-white">{currentPage}</span> dari{" "}
                {totalPages}
              </span>
              <PaginationControls
                currentPage={currentPage}
                totalPages={totalPages}
                setCurrentPage={setCurrentPage}
                getPageNumbers={getPageNumbers}
              />
            </div>
          )}
        </Card>
      )}

      <ReceiptModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        transaction={selectedTransaction}
      />

      <ConfirmDialog
        isOpen={!!refundTarget}
        onClose={() => setRefundTarget(null)}
        onConfirm={() => handleRefund(refundTarget)}
        title="Konfirmasi Refund"
        message="Apakah Anda yakin ingin melakukan refund transaksi ini? Aksi ini tidak dapat dibatalkan."
        confirmText="Ya, Refund"
        variant="danger"
      />
    </div>
  );
}

const PaginationControls = ({
  currentPage,
  totalPages,
  setCurrentPage,
  getPageNumbers,
  mobile,
}) => (
  <div className="flex items-center gap-1">
    <button
      onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
      disabled={currentPage === 1}
      className={`p-2 bg-gray-900 border border-white/5 rounded-lg text-gray-400 hover:text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all ${mobile ? "flex-1" : ""}`}
    >
      <svg
        className="w-5 h-5 mx-auto"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="15 19l-7-7 7-7"
        />
      </svg>
    </button>

    {!mobile && (
      <div className="flex gap-1 mx-2">
        {getPageNumbers().map((page) => (
          <button
            key={page}
            onClick={() => setCurrentPage(page)}
            className={`w-10 h-10 rounded-lg font-bold text-sm transition-all border ${
              currentPage === page
                ? "bg-blue-600 border-blue-500 text-white shadow-lg shadow-blue-500/20"
                : "bg-gray-900 border-white/5 text-gray-500 hover:text-white hover:border-gray-700"
            }`}
          >
            {page}
          </button>
        ))}
      </div>
    )}

    {mobile && (
      <span className="px-4 text-sm font-bold text-gray-400">
        {currentPage} / {totalPages}
      </span>
    )}

    <button
      onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
      disabled={currentPage === totalPages}
      className={`p-2 bg-gray-900 border border-white/5 rounded-lg text-gray-400 hover:text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all ${mobile ? "flex-1" : ""}`}
    >
      <svg
        className="w-5 h-5 mx-auto"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="9 5l7 7-7 7"
        />
      </svg>
    </button>
  </div>
);

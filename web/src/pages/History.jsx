import { useEffect, useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  getTransactionHistory,
  refundTransaction,
} from "../services/transactionService";
import ReceiptModal from "../components/transactions/ReceiptModal";
import {
  FaCalendarAlt,
  FaHistory,
  FaSearch,
  FaUndo,
  FaEye,
  FaMoneyBillWave,
  FaCheckCircle,
  FaTimesCircle,
} from "react-icons/fa";

const StatusBadge = ({ status }) => {
  const styles = {
    completed: "bg-green-500/10 text-green-400 border-green-500/20",
    refunded: "bg-red-500/10 text-red-400 border-red-500/20",
    pending: "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
    cancelled: "bg-gray-500/10 text-gray-400 border-gray-500/20",
  };

  return (
    <span
      className={`px-2.5 py-0.5 rounded-full text-xs font-medium border ${styles[status] || styles.pending}`}
    >
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  );
};

const SummaryCard = ({ title, value, icon: Icon, colorClass }) => (
  <div className="bg-gray-900/50 backdrop-blur-sm p-4 rounded-xl border border-white/5 shadow-lg">
    <div className="flex items-center justify-between gap-4">
      <div>
        <p className="text-gray-400 text-xs font-bold uppercase tracking-wider">
          {title}
        </p>
        <h3 className={`text-xl font-bold mt-1 ${colorClass}`}>{value}</h3>
      </div>
      <div className={`p-3 rounded-lg bg-white/5 ${colorClass}`}>
        <Icon className="text-xl opacity-80" />
      </div>
    </div>
  </div>
);

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

  // Stats calculation (based on current page)
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
      revenue: `Rp ${totalRevenue.toLocaleString()}`,
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
      await fetchHistory(currentPage, filterDate);
    } catch (err) {
      console.error("Refund failed:", err);
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

  // Pagination logic
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
    <div className="p-4 sm:p-6 bg-gray-950 min-h-screen text-gray-100 font-sans">
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight flex items-center gap-2">
            <FaHistory className="text-blue-500 text-2xl" />
            Transaction History
          </h1>
          <p className="text-gray-400 text-sm mt-1">
            Review and manage your past sales
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <FaCalendarAlt className="text-gray-500 group-focus-within:text-blue-500 transition-colors" />
            </div>
            <input
              type="date"
              value={filterDate}
              onChange={handleDateChange}
              className="bg-gray-900 border border-white/10 text-white pl-10 pr-3 py-2 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/50 transition-all hover:bg-gray-800"
            />
          </div>
          {filterDate && (
            <button
              onClick={clearFilter}
              className="bg-gray-800 hover:bg-gray-700 text-gray-300 px-4 py-2 rounded-xl transition-all border border-white/5 active:scale-95 text-sm font-semibold"
            >
              All Time
            </button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <SummaryCard
          title="Revenue (This View)"
          value={stats.revenue}
          icon={FaMoneyBillWave}
          colorClass="text-green-400"
        />
        <SummaryCard
          title="Completed"
          value={stats.completed}
          icon={FaCheckCircle}
          colorClass="text-blue-400"
        />
        <SummaryCard
          title="Refunded"
          value={stats.refunded}
          icon={FaTimesCircle}
          colorClass="text-red-400"
        />
      </div>

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20">
          <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-gray-500 mt-4 animate-pulse">
            Fetching transactions...
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {/* Mobile View: Cards */}
          <div className="grid grid-cols-1 gap-4 md:hidden">
            <AnimatePresence mode="popLayout">
              {transactions.map((trx, idx) => {
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
                  <motion.div
                    key={trx.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.05 }}
                    className="bg-gray-900/60 backdrop-blur-md rounded-2xl p-5 border border-white/5 shadow-lg space-y-4"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="text-xs font-mono text-gray-500 mb-1">
                          #{trx.id}
                        </p>
                        <p className="text-lg font-bold text-white tracking-tight">
                          Rp {trx.total?.toLocaleString() || 0}
                        </p>
                      </div>
                      <StatusBadge status={trx.status} />
                    </div>

                    <div className="flex justify-between items-center text-xs text-gray-400 border-t border-white/5 pt-3">
                      <span>{formattedDate}</span>
                      <div className="flex gap-2">
                        <button
                          onClick={() => viewDetails(trx)}
                          className="flex items-center gap-1.5 px-3 py-1.5 bg-blue-600/10 text-blue-400 rounded-lg font-bold border border-blue-500/20 active:scale-95"
                        >
                          <FaEye className="text-xs" /> Details
                        </button>
                        {trx.status === "completed" && (
                          <button
                            onClick={() => handleRefund(trx.id)}
                            className="flex items-center gap-1.5 px-3 py-1.5 bg-red-600/10 text-red-500 rounded-lg font-bold border border-red-500/20 active:scale-95"
                          >
                            <FaUndo className="text-xs" /> Refund
                          </button>
                        )}
                      </div>
                    </div>
                  </motion.div>
                );
              })}
            </AnimatePresence>
          </div>

          {/* Desktop View: Table */}
          <div className="hidden md:block bg-gray-900/40 backdrop-blur-md rounded-2xl shadow-xl border border-white/5 overflow-hidden">
            <div className="overflow-x-auto overflow-y-hidden">
              <table className="w-full text-left">
                <thead>
                  <tr className="bg-gray-950/50 text-gray-400 border-b border-gray-800 text-xs font-bold uppercase tracking-widest">
                    <th className="px-6 py-4">ID</th>
                    <th className="px-6 py-4">Status</th>
                    <th className="px-6 py-4">Total</th>
                    <th className="px-6 py-4">Date</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-800/50">
                  <AnimatePresence mode="popLayout">
                    {transactions.map((trx, idx) => {
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
                        <motion.tr
                          key={trx.id}
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, scale: 0.95 }}
                          transition={{ delay: idx * 0.05 }}
                          className="hover:bg-white/5 transition-all group"
                        >
                          <td className="px-6 py-4 font-mono text-xs text-gray-500 group-hover:text-blue-400 transition-colors">
                            #{trx.id}
                          </td>
                          <td className="px-6 py-4">
                            <StatusBadge status={trx.status} />
                          </td>
                          <td className="px-6 py-4">
                            <span className="font-bold text-white tracking-tight">
                              Rp {trx.total?.toLocaleString() || 0}
                            </span>
                          </td>
                          <td className="px-6 py-4 text-sm text-gray-400">
                            {formattedDate}
                          </td>
                          <td className="px-6 py-4 text-right">
                            <div className="flex items-center justify-end gap-2">
                              <button
                                title="Details"
                                className="p-2 bg-blue-600/10 hover:bg-blue-600 text-blue-400 hover:text-white rounded-lg transition-all active:scale-90"
                                onClick={() => viewDetails(trx)}
                              >
                                <FaEye />
                              </button>

                              {trx.status === "completed" && (
                                <button
                                  title="Refund"
                                  className="p-2 bg-red-600/10 hover:bg-red-600 text-red-500 hover:text-white rounded-lg transition-all active:scale-90"
                                  onClick={() => handleRefund(trx.id)}
                                >
                                  <FaUndo />
                                </button>
                              )}
                            </div>
                          </td>
                        </motion.tr>
                      );
                    })}
                  </AnimatePresence>
                </tbody>
              </table>
            </div>

            {transactions.length === 0 && (
              <div className="flex flex-col items-center justify-center py-20 bg-gray-900/20">
                <FaSearch className="text-gray-800 text-6xl mb-4" />
                <p className="text-gray-500 font-medium">
                  No transactions found match your criteria.
                </p>
              </div>
            )}

            {/* Pagination Desktop (Integrated into Table) */}
            {totalPages > 1 && (
              <div className="bg-gray-950/30 p-4 border-t border-gray-800 flex items-center justify-between">
                <p className="text-xs text-gray-500 font-medium uppercase tracking-widest">
                  Page <span className="text-gray-300">{currentPage}</span> of{" "}
                  <span className="text-gray-300">{totalPages}</span>
                </p>
                <PaginationControls
                  currentPage={currentPage}
                  totalPages={totalPages}
                  setCurrentPage={setCurrentPage}
                  getPageNumbers={getPageNumbers}
                />
              </div>
            )}
          </div>

          {/* Mobile Empty State */}
          {transactions.length === 0 && !loading && (
            <div className="flex flex-col items-center justify-center py-20 md:hidden bg-gray-900/20 rounded-2xl border border-white/5">
              <FaSearch className="text-gray-800 text-6xl mb-4" />
              <p className="text-gray-500 font-medium text-center px-6">
                No transactions found match your criteria.
              </p>
            </div>
          )}

          {/* Mobile Pagination */}
          <div className="md:hidden pt-4">
            {totalPages > 1 && (
              <div className="flex flex-col items-center gap-4">
                <PaginationControls
                  currentPage={currentPage}
                  totalPages={totalPages}
                  setCurrentPage={setCurrentPage}
                  getPageNumbers={getPageNumbers}
                  mobile
                />
              </div>
            )}
          </div>
        </div>
      )}

      <ReceiptModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        transaction={selectedTransaction}
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

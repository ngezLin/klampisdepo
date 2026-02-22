import { useEffect, useState } from "react";
import {
  getTransactionHistory,
  refundTransaction,
} from "../services/transactionService";
import TransactionDetailModal from "../components/history/TransactionDetailModal";

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
      if (selectedTransaction && selectedTransaction.id === id) {
        setSelectedTransaction({
          ...selectedTransaction,
          status: "refunded",
        });
      }
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
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Transaction History</h1>

      <div className="mb-4">
        <label className="mr-2 font-medium">Filter by Date:</label>
        <input
          type="date"
          value={filterDate}
          onChange={handleDateChange}
          className="border px-2 py-1 rounded"
        />
        {filterDate && (
          <button
            onClick={clearFilter}
            className="ml-2 bg-gray-300 px-2 py-1 rounded"
          >
            Clear
          </button>
        )}
      </div>

      {loading ? (
        <p className="text-gray-600">Loading...</p>
      ) : transactions.length === 0 ? (
        <p className="text-gray-600">No transactions found.</p>
      ) : (
        <table className="w-full border border-gray-300 text-sm">
          <thead>
            <tr className="bg-gray-100">
              <th className="border p-2 text-left">ID</th>
              <th className="border p-2 text-left">Status</th>
              <th className="border p-2 text-left">Total</th>
              <th className="border p-2 text-left">Date</th>
              <th className="border p-2 text-left">Action</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((trx) => {
              const dateObj =
                typeof trx.created_at === "number"
                  ? new Date(trx.created_at * 1000)
                  : new Date(trx.created_at);
              const formattedDate = isNaN(dateObj.getTime())
                ? "-"
                : dateObj.toLocaleString("id-ID", {
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit",
                  });
              return (
                <tr key={trx.id}>
                  <td className="border p-2 text-left">{trx.id}</td>
                  <td className="border p-2 text-left">{trx.status}</td>
                  <td className="border p-2 text-left">
                    Rp {trx.total?.toLocaleString() || 0}
                  </td>
                  <td className="border p-2 text-left">{formattedDate}</td>
                  <td className="border p-2 text-left space-x-2">
                    <button
                      className="bg-blue-500 text-white px-2 py-1 rounded"
                      onClick={() => viewDetails(trx)}
                    >
                      View Detail
                    </button>

                    {trx.status === "completed" && (
                      <button
                        className="bg-red-500 text-white px-2 py-1 rounded"
                        onClick={() => handleRefund(trx.id)}
                      >
                        Refund
                      </button>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center mt-4 space-x-2">
          <button
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            Prev
          </button>

          {currentPage > 3 && totalPages > 5 && (
            <>
              <button
                onClick={() => setCurrentPage(1)}
                className="px-3 py-1 border rounded"
              >
                1
              </button>
              <span className="px-2">...</span>
            </>
          )}

          {getPageNumbers().map((page) => (
            <button
              key={page}
              onClick={() => setCurrentPage(page)}
              className={`px-3 py-1 border rounded ${
                currentPage === page ? "bg-blue-500 text-white" : ""
              }`}
            >
              {page}
            </button>
          ))}

          {currentPage < totalPages - 2 && totalPages > 5 && (
            <>
              <span className="px-2">...</span>
              <button
                onClick={() => setCurrentPage(totalPages)}
                className="px-3 py-1 border rounded"
              >
                {totalPages}
              </button>
            </>
          )}

          <button
            onClick={() =>
              setCurrentPage((prev) => Math.min(prev + 1, totalPages))
            }
            disabled={currentPage === totalPages}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            Next
          </button>
        </div>
      )}

      <TransactionDetailModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        transaction={selectedTransaction}
      />
    </div>
  );
}

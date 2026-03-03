import React from "react";

export default function Pagination({
  currentPage,
  totalPages,
  totalItems,
  itemsPerPage,
  currentItemsCount,
  onNext,
  onPrevious,
  onPageChange,
}) {
  const getPageNumbers = () => {
    const pages = [];
    const maxPagesToShow = 5;

    if (totalPages <= maxPagesToShow) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      pages.push(1);

      let startPage = Math.max(2, currentPage - 1);
      let endPage = Math.min(totalPages - 1, currentPage + 1);

      if (startPage > 2) {
        pages.push("...");
      }

      for (let i = startPage; i <= endPage; i++) {
        pages.push(i);
      }

      if (endPage < totalPages - 1) {
        pages.push("...");
      }

      pages.push(totalPages);
    }

    return pages;
  };

  return (
    <div className="flex flex-col sm:flex-row justify-between items-center mt-4 gap-4">
      <div className="text-sm text-gray-500">
        Showing{" "}
        <span className="text-gray-300 font-medium">
          {currentItemsCount > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0}
        </span>{" "}
        to{" "}
        <span className="text-gray-300 font-medium">
          {Math.min(currentPage * itemsPerPage, totalItems)}
        </span>{" "}
        of <span className="text-gray-300 font-medium">{totalItems}</span> items
      </div>

      <div className="flex items-center gap-2">
        <button
          onClick={onPrevious}
          disabled={currentPage === 1}
          className={`px-3 py-1 rounded-lg border text-sm transition-all ${
            currentPage === 1
              ? "bg-gray-800/50 border-gray-700 text-gray-600 cursor-not-allowed"
              : "bg-gray-800 border-gray-700 text-gray-300 hover:bg-gray-700 hover:text-white"
          }`}
        >
          Previous
        </button>

        <div className="flex gap-1">
          {getPageNumbers().map((page, index) =>
            page === "..." ? (
              <span
                key={`ellipsis-${index}`}
                className="px-2 py-1 text-gray-500"
              >
                ...
              </span>
            ) : (
              <button
                key={page}
                onClick={() => onPageChange(page)}
                className={`px-3 py-1 rounded-lg border text-sm transition-all ${
                  currentPage === page
                    ? "bg-blue-600 border-blue-500 text-white shadow-lg shadow-blue-500/20"
                    : "bg-gray-800 border-gray-700 text-gray-400 hover:bg-gray-700 hover:text-white"
                }`}
              >
                {page}
              </button>
            ),
          )}
        </div>

        <button
          onClick={onNext}
          disabled={currentPage >= totalPages}
          className={`px-3 py-1 rounded-lg border text-sm transition-all ${
            currentPage >= totalPages
              ? "bg-gray-800/50 border-gray-700 text-gray-600 cursor-not-allowed"
              : "bg-gray-800 border-gray-700 text-gray-300 hover:bg-gray-700 hover:text-white"
          }`}
        >
          Next
        </button>
      </div>
    </div>
  );
}

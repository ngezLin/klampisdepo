import api from "../../services/api";
import toast from "react-hot-toast";

export default function DraftModal({
  drafts,
  isOpen,
  closeModal,
  loadDraft,
  fetchDrafts,
}) {
  if (!isOpen) return null;

  const handleDeleteDraft = async (id) => {
    try {
      await api.delete(`/transactions/${id}`);
      toast.success("Draft berhasil dihapus");
      fetchDrafts();
    } catch (err) {
      console.error(err);
      toast.error("Gagal hapus draft");
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-6 rounded w-full max-w-2xl max-h-[80vh] overflow-y-auto relative shadow-lg">
        <h2 className="text-xl font-bold mb-4">Draft Transactions</h2>

        <button
          className="absolute top-2 right-2 text-red-500 font-bold"
          onClick={closeModal}
        >
          X
        </button>

        {drafts.length === 0 ? (
          <p className="text-gray-500">No drafts available</p>
        ) : (
          drafts.map((d) => (
            <div
              key={d.id}
              className="p-3 bg-gray-100 rounded mb-2 shadow-sm hover:bg-gray-200 transition"
            >
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <p className="font-semibold">Note: {d.note ? d.note : "-"}</p>
                  <p className="text-sm text-gray-600">Status: {d.status}</p>
                  <p className="text-sm text-gray-600">
                    Total Items: {d.items?.length || 0}
                  </p>

                  {d.items && d.items.length > 0 && (
                    <ul className="mt-2 text-sm text-gray-700 list-disc list-inside">
                      {d.items.slice(0, 3).map((i, idx) => (
                        <li key={idx}>
                          {i.item?.name || "Unknown"}{" "}
                          <span className="text-gray-500">(x{i.quantity})</span>
                        </li>
                      ))}
                      {d.items.length > 3 && (
                        <li className="italic text-gray-500">
                          +{d.items.length - 3} more items
                        </li>
                      )}
                    </ul>
                  )}
                </div>

                <div className="flex flex-col gap-2 ml-3">
                  <button
                    className="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded text-sm"
                    onClick={() => {
                      loadDraft(d.id);
                      toast("Draft dimuat");
                    }}
                  >
                    Load
                  </button>

                  <button
                    className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm"
                    onClick={() => handleDeleteDraft(d.id)}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

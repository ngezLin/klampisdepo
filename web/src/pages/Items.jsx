import { useEffect, useState, useCallback } from "react";
import {
  getItems,
  searchItemsByName,
  createItem,
  updateItem,
  deleteItem,
  importItems,
  exportItemsCSV,
} from "../services/itemService";
import ItemForm from "../components/items/ItemForm";
import ItemTable from "../components/items/ItemTable";
import ImportModal from "../components/items/ImportModal";
import Pagination from "../components/common/Pagination";
import ConfirmDialog from "../components/common/ConfirmDialog";
import Button from "../components/common/Button";
import toast from "react-hot-toast";
import { Plus, FileUp, FileDown, Search } from "lucide-react";

export default function Items() {
  const [items, setItems] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [exporting, setExporting] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState(null);

  // Backend pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const itemsPerPage = 100;

  const fetchItems = useCallback(
    async (page = 1, search = "") => {
      setLoading(true);
      setError("");
      try {
        let response;
        if (search.trim()) {
          response = await searchItemsByName(search.trim(), page, itemsPerPage);
        } else {
          response = await getItems(page, itemsPerPage);
        }

        const { data, meta } = response;

        setItems(data || []);
        setCurrentPage(meta?.page ?? 1);
        setTotalPages(meta?.total_pages ?? meta?.totalPages ?? 1);
        setTotalItems(meta?.total_items ?? meta?.total ?? 0);
      } catch (err) {
        setError("Gagal mengambil data items");
        console.error(err);
        setItems([]);
      } finally {
        setLoading(false);
      }
    },
    [itemsPerPage],
  );

  useEffect(() => {
    fetchItems(currentPage, searchQuery);
  }, [currentPage, searchQuery, fetchItems]);

  const handleAdd = () => {
    setSelectedItem(null);
    setIsModalOpen(true);
  };

  const handleEdit = (item) => {
    setSelectedItem(item);
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    try {
      await deleteItem(id);
      setDeleteTarget(null);
      fetchItems(currentPage, searchQuery);
      toast.success("Item berhasil dihapus");
    } catch (err) {
      setError("Gagal menghapus item");
      console.error(err);
    }
  };

  const handleSubmit = async (formData) => {
    try {
      if (selectedItem) {
        await updateItem(selectedItem.id, formData);
      } else {
        await createItem(formData);
      }
      setIsModalOpen(false);
      fetchItems(currentPage, searchQuery);
    } catch (err) {
      setError("Gagal menyimpan item");
      console.error(err);
    }
  };

  const handleExport = async () => {
    setExporting(true);
    setError("");
    try {
      const blob = await exportItemsCSV();

      // Create download link
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;

      // Generate filename with current date
      const date = new Date().toISOString().split("T")[0];
      link.download = `items_export_${date}.csv`;

      // Trigger download
      document.body.appendChild(link);
      link.click();

      // Cleanup
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);

      toast.success("✅ Export berhasil!");
    } catch (err) {
      setError("Gagal mengekspor items");
      console.error(err);
      toast.error("❌ Export gagal. Silakan coba lagi.");
    } finally {
      setExporting(false);
    }
  };

  const handleImportItems = async (itemsFromExcel) => {
    try {
      const formattedItems = itemsFromExcel.map((item) => {
        const get = (...keys) => {
          for (const k of keys) {
            if (
              k in item &&
              item[k] !== null &&
              item[k] !== undefined &&
              item[k] !== ""
            ) {
              return item[k];
            }
          }
          return undefined;
        };

        const name = get("name", "Name", "Nama", "nama") || "";
        const description =
          get("description", "Description", "desc", "Desc") || null;

        const stockRaw = get("stock", "Stock", "STOCK");
        const buyRaw = get(
          "buy_price",
          "buyPrice",
          "BuyPrice",
          "Buyprice",
          "Buy_Price",
        );
        const priceRaw = get("price", "Price", "PRICE");
        const imageRaw = get(
          "image_url",
          "imageurl",
          "ImageUrl",
          "ImageURL",
          "image",
        );

        const safeNumber = (n) => (Number.isFinite(Number(n)) ? Number(n) : 0);

        return {
          name: name.toString().trim(),
          description: description ? description.toString().trim() : null,
          stock: safeNumber(stockRaw),
          buy_price: safeNumber(buyRaw),
          price: safeNumber(priceRaw),
          image_url: imageRaw ? imageRaw.toString().trim() : null,
        };
      });

      const chunkSize = 400;
      const chunks = [];
      for (let i = 0; i < formattedItems.length; i += chunkSize) {
        chunks.push(formattedItems.slice(i, i + chunkSize));
      }

      let totalSuccess = 0;
      for (let i = 0; i < chunks.length; i++) {
        const batch = chunks[i];
        console.log(`⏳ Upload batch ${i + 1} (${batch.length} items)`);

        try {
          await importItems(batch);
          totalSuccess += batch.length;
          console.log(`✅ Batch ${i + 1} berhasil`);
        } catch (err) {
          console.error(
            `❌ Gagal upload batch ${i + 1}:`,
            err.response?.data || err.message,
          );
        }
      }

      toast.success(`✅ Import selesai! Total item berhasil: ${totalSuccess}`);
      setSearchQuery("");
      setCurrentPage(1);
      fetchItems(1, "");
      setIsImportModalOpen(false);
    } catch (err) {
      setError("Gagal mengimpor items dari Excel");
      console.error(err);
    }
  };

  return (
    <div className="p-4 sm:p-6 bg-gray-950 min-h-screen text-gray-100">
      <h1 className="text-2xl sm:text-3xl font-bold mb-6 text-white tracking-tight">
        Manajemen Inventori
      </h1>

      <div className="flex flex-col sm:flex-row gap-2 mb-4">
        <Button
          variant="success"
          icon={Plus}
          onClick={handleAdd}
          className="w-full sm:w-auto"
        >
          Tambah Item
        </Button>
        <Button
          variant="primary"
          icon={FileUp}
          onClick={() => setIsImportModalOpen(true)}
          className="w-full sm:w-auto"
        >
          Import Excel
        </Button>
        <Button
          variant="purple"
          icon={FileDown}
          onClick={handleExport}
          disabled={exporting || totalItems === 0}
          loading={exporting}
          className="w-full sm:w-auto"
        >
          {exporting ? "Exporting..." : "Export CSV"}
        </Button>
      </div>

      <div className="mb-4">
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search className="w-4 h-4 text-gray-500" />
          </div>
          <input
            type="text"
            placeholder="Cari item berdasarkan nama..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="bg-gray-900 border border-white/10 rounded-xl w-full pl-10 pr-3 py-2.5 text-white placeholder-gray-500 focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
          />
        </div>
        <p className="text-sm text-gray-400 mt-1">Total: {totalItems} items</p>
      </div>

      {error && <p className="text-red-600 mb-2">{error}</p>}

      {loading ? (
        <div className="flex justify-center items-center py-8">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      ) : items.length === 0 ? (
        <div className="text-center py-8">
          <p className="text-gray-500">
            {searchQuery
              ? "Tidak ada item yang cocok dengan pencarian"
              : "Belum ada item"}
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <ItemTable
            items={items}
            onEdit={handleEdit}
            onDelete={(id) => setDeleteTarget(id)}
          />

          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            totalItems={totalItems}
            itemsPerPage={itemsPerPage}
            currentItemsCount={items.length}
            onNext={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
            onPrevious={() => setCurrentPage((p) => Math.max(p - 1, 1))}
            onPageChange={setCurrentPage}
          />
        </div>
      )}

      <ItemForm
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        initialData={selectedItem}
      />

      <ImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        onImport={handleImportItems}
      />

      <ConfirmDialog
        isOpen={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => handleDelete(deleteTarget)}
        title="Hapus Item"
        message="Apakah Anda yakin ingin menghapus item ini? Stok dan data item akan hilang."
        confirmText="Ya, Hapus"
        variant="danger"
      />
    </div>
  );
}

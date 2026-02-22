// D:\project\js\react\kd-frontend\src\components\ImportItems.jsx
import { useState } from "react";
import * as XLSX from "xlsx";

export default function ImportItems({ onImport }) {
  const [file, setFile] = useState(null);
  const [error, setError] = useState("");

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
    setError("");
  };

  const handleImport = () => {
    if (!file) {
      setError("Pilih file Excel terlebih dahulu");
      return;
    }

    const reader = new FileReader();
    reader.onload = (evt) => {
      const data = evt.target.result;
      // NOTE: gunakan array buffer yang lebih reliable di banyak browser
      const workbook = XLSX.read(data, { type: "array" });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];

      // defval: "" -> pastikan sel kosong tidak diabaikan
      const rows = XLSX.utils.sheet_to_json(sheet, { defval: "" });

      if (!rows.length) {
        setError("File kosong atau tidak ada data yang bisa dibaca");
        return;
      }

      // Kirim rows mentah ke parent, biarkan parent melakukan normalisasi/mapping
      onImport(rows);
    };

    // read as array buffer
    reader.readAsArrayBuffer(file);
  };

  return (
    <div className="p-4 border rounded bg-white shadow-sm">
      <label className="block mb-2 font-medium">
        Import Excel (.xlsx / .xls)
      </label>
      <input
        type="file"
        accept=".xlsx, .xls"
        onChange={handleFileChange}
        className="mb-3"
      />

      <button
        onClick={handleImport}
        className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
      >
        Import
      </button>

      {error && <p className="text-red-600 mt-2">{error}</p>}
    </div>
  );
}

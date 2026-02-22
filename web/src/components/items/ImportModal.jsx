import React from "react";
import ImportItems from "./ImportItems";

export default function ImportModal({ isOpen, onClose, onImport }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50 px-4">
      <div className="bg-white p-6 rounded shadow-lg w-full max-w-md">
        <h2 className="text-lg font-bold mb-4">Import Items from Excel</h2>
        <ImportItems onImport={onImport} />
        <button
          onClick={onClose}
          className="mt-4 bg-gray-400 hover:bg-gray-500 text-white px-4 py-2 rounded w-full"
        >
          Close
        </button>
      </div>
    </div>
  );
}

import { SearchX } from "lucide-react";

export default function EmptyState({
  icon: Icon = SearchX,
  title = "Tidak ada data",
  description,
}) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-6">
      <div className="p-4 bg-gray-800/50 rounded-2xl mb-4">
        <Icon className="w-10 h-10 text-gray-600" />
      </div>
      <p className="text-gray-400 font-semibold text-sm">{title}</p>
      {description && (
        <p className="text-gray-600 text-xs mt-1 text-center max-w-xs">
          {description}
        </p>
      )}
    </div>
  );
}

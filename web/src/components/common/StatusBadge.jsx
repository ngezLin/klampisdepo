const styles = {
  completed: "bg-green-500/10 text-green-400 border-green-500/20",
  refunded: "bg-red-500/10 text-red-400 border-red-500/20",
  pending: "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
  cancelled: "bg-gray-500/10 text-gray-400 border-gray-500/20",
  draft: "bg-blue-500/10 text-blue-400 border-blue-500/20",
};

export default function StatusBadge({ status, size = "sm" }) {
  const sizeClass =
    size === "xs" ? "px-2 py-0.5 text-[10px]" : "px-2.5 py-0.5 text-xs";

  return (
    <span
      className={`inline-flex items-center rounded-full font-bold uppercase border tracking-wide ${sizeClass} ${
        styles[status] || styles.pending
      }`}
    >
      {status?.charAt(0).toUpperCase() + status?.slice(1)}
    </span>
  );
}

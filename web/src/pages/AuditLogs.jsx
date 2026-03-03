import { useEffect, useState, useCallback } from "react";
import { getAuditLogs } from "../services/auditLogService";

export default function AuditLogs() {
  const [logs, setLogs] = useState([]);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

  const pageSize = 20;

  const fetchLogs = useCallback(async () => {
    setLoading(true);
    try {
      const res = await getAuditLogs({
        page,
        page_size: pageSize,
      });
      setLogs(res.data);
      setTotal(res.total_items);
    } catch (err) {
      console.error("Failed to fetch audit logs", err);
    } finally {
      setLoading(false);
    }
  }, [page]);

  useEffect(() => {
    fetchLogs();
  }, [fetchLogs]);

  const totalPages = Math.ceil(total / pageSize);

  const renderChanges = (changes) => {
    if (!changes) return null;

    let parsed;
    try {
      parsed = JSON.parse(changes);
    } catch {
      return null;
    }

    return (
      <ul className="mt-1 space-y-0.5 text-xs text-gray-400">
        {Object.entries(parsed).map(([field, value]) => (
          <li key={field}>
            <span className="font-semibold">{field}</span>:{" "}
            <span className="text-red-600">{String(value.old)}</span> →{" "}
            <span className="text-green-600">{String(value.new)}</span>
          </li>
        ))}
      </ul>
    );
  };

  const actionBadge = (action) => {
    const base = "px-2 py-1 rounded text-xs font-semibold capitalize";
    if (action === "create")
      return (
        <span className={`${base} bg-green-100 text-green-700`}>{action}</span>
      );
    if (action === "update")
      return (
        <span className={`${base} bg-yellow-100 text-yellow-700`}>
          {action}
        </span>
      );
    if (action === "delete")
      return (
        <span className={`${base} bg-red-100 text-red-700`}>{action}</span>
      );
    return (
      <span className={`${base} bg-gray-100 text-gray-700`}>{action}</span>
    );
  };

  return (
    <div className="p-4 sm:p-6 bg-gray-950 min-h-screen text-gray-100">
      <h1 className="text-2xl font-bold mb-4 text-white">Audit Logs</h1>

      {loading ? (
        <p>Loading...</p>
      ) : (
        <div className="overflow-x-auto bg-gray-900/50 backdrop-blur-sm rounded-xl shadow-lg border border-white/5">
          <table className="min-w-full text-sm">
            <thead className="bg-gray-900 text-gray-300 border-b border-gray-800">
              <tr>
                <th className="p-3">Time</th>
                <th className="p-3">Entity</th>
                <th className="p-3">Action</th>
                <th className="p-3">User</th>
                <th className="p-3">Description</th>
              </tr>
            </thead>
            <tbody>
              {logs.map((log) => (
                <tr
                  key={log.id}
                  className="border-t border-gray-800 align-top hover:bg-white/5 transition-colors"
                >
                  <td className="p-3 whitespace-nowrap">
                    {new Date(log.created_at).toLocaleString()}
                  </td>
                  <td className="p-3">
                    {log.entity_type} #{log.entity_id}
                  </td>
                  <td className="p-3">{actionBadge(log.action)}</td>
                  <td className="p-3">
                    {log.user?.name || log.user_id || "-"}
                  </td>
                  <td className="p-3 max-w-md">
                    <div className="font-medium">{log.description}</div>
                    {renderChanges(log.changes)}
                  </td>
                </tr>
              ))}

              {logs.length === 0 && (
                <tr>
                  <td
                    colSpan={5}
                    className="p-4 text-center text-gray-500 italic"
                  >
                    No audit logs found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      <div className="flex justify-between items-center mt-6">
        <span className="text-sm text-gray-500">
          Page <span className="text-gray-300 font-bold">{page}</span> of{" "}
          <span className="text-gray-300 font-bold">{totalPages || 1}</span>
        </span>
        <div className="flex gap-2">
          <button
            disabled={page === 1}
            onClick={() => setPage(page - 1)}
            className="px-4 py-1.5 bg-gray-800 border border-gray-700 text-gray-300 rounded-lg disabled:opacity-30 hover:bg-gray-700 transition-colors"
          >
            Prev
          </button>
          <button
            disabled={page >= totalPages}
            onClick={() => setPage(page + 1)}
            className="px-4 py-1.5 bg-gray-800 border border-gray-700 text-gray-300 rounded-lg disabled:opacity-30 hover:bg-gray-700 transition-colors"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
}

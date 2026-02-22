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
      <ul className="mt-1 space-y-0.5 text-xs text-gray-600">
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
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Audit Logs</h1>

      {loading ? (
        <p>Loading...</p>
      ) : (
        <div className="overflow-x-auto bg-white rounded shadow">
          <table className="min-w-full text-sm">
            <thead className="bg-gray-100 text-left">
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
                <tr key={log.id} className="border-t align-top">
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
                  <td colSpan={5} className="p-4 text-center text-gray-500">
                    No audit logs found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      <div className="flex justify-between items-center mt-4">
        <span className="text-sm text-gray-600">
          Page {page} of {totalPages || 1}
        </span>
        <div className="space-x-2">
          <button
            disabled={page === 1}
            onClick={() => setPage(page - 1)}
            className="px-3 py-1 bg-gray-200 rounded disabled:opacity-50"
          >
            Prev
          </button>
          <button
            disabled={page >= totalPages}
            onClick={() => setPage(page + 1)}
            className="px-3 py-1 bg-gray-200 rounded disabled:opacity-50"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
}

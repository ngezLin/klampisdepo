"use client";

import { useState, useEffect } from "react";
import { attendanceService } from "../services/attendanceService";
import { userService } from "../services/userService";
import toast from "react-hot-toast";

export default function Attendance() {
  const [activeTab, setActiveTab] = useState("today");
  const [todayAttendance, setTodayAttendance] = useState([]);
  const [allAttendance, setAllAttendance] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Form state
  const [formData, setFormData] = useState({
    user_id: "",
    status: "present",
    note: "",
  });

  useEffect(() => {
    if (activeTab === "today") {
      fetchTodayAttendance();
    } else if (activeTab === "history") {
      fetchAllAttendance();
    }
  }, [activeTab]);

  const fetchTodayAttendance = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await attendanceService.getTodayAttendance();
      setTodayAttendance(data);
    } catch (err) {
      setError("Failed to fetch today's attendance");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchAllAttendance = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await attendanceService.getAttendanceHistory();
      setAllAttendance(data);
    } catch (err) {
      setError("Failed to fetch attendance history");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await attendanceService.createAttendance({
        user_id: Number.parseInt(formData.user_id),
        status: formData.status,
        note: formData.note,
      });

      // Reset form
      setFormData({ user_id: "", status: "present", note: "" });

      // Refresh data
      fetchTodayAttendance();
      toast("Attendance recorded successfully!");
    } catch (err) {
      setError(err.response?.data?.error || "Failed to create attendance");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString("id-ID", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getStatusBadge = (status) => {
    const styles = {
      present: "bg-green-900/30 text-green-400 border border-green-800/50",
      absent: "bg-red-900/30 text-red-400 border border-red-800/50",
      sick: "bg-yellow-900/30 text-yellow-400 border border-yellow-800/50",
      leave: "bg-blue-900/30 text-blue-400 border border-blue-800/50",
    };
    return styles[status] || "bg-gray-800 text-gray-400 border border-gray-700";
  };

  useEffect(() => {
    let isMounted = true;

    async function loadUsers() {
      try {
        const data = await userService.getUsers();
        if (isMounted) setUsers(data || []);
      } catch (err) {
        // Keep existing error UX; only show if not an admin is already handled by your filter
        console.error("Failed to fetch users:", err);
        if (isMounted) setError("Failed to load users");
      }
    }

    loadUsers();
    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <div className="p-4 sm:p-6 bg-gray-950 min-h-screen text-gray-100">
      <h1 className="text-3xl font-bold mb-6 text-white tracking-tight">
        Attendance Management
      </h1>

      {/* Create Attendance Form */}
      <div className="bg-gray-900/50 backdrop-blur-sm rounded-2xl shadow-xl p-6 mb-8 border border-white/5">
        <h2 className="text-xl font-semibold mb-6 text-white flex items-center gap-2">
          <span className="h-2 w-2 bg-blue-500 rounded-full animate-pulse" />
          Record Attendance
        </h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-400 mb-2 ml-1">
                Employee
              </label>
              <select
                value={formData.user_id}
                onChange={(e) =>
                  setFormData({ ...formData, user_id: e.target.value })
                }
                className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2.5 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
                required
              >
                <option value="">Select Employee</option>
                {users.map((user) => (
                  <option key={user.id} value={user.id}>
                    {user.username} ({user.role})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-bold text-gray-400 mb-2 ml-1">
                Status
              </label>
              <select
                value={formData.status}
                onChange={(e) =>
                  setFormData({ ...formData, status: e.target.value })
                }
                className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2.5 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
                required
              >
                <option value="present">Present</option>
                <option value="absent">Absent</option>
                <option value="sick">Sick</option>
                <option value="leave">Leave</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-bold text-gray-400 mb-2 ml-1">
                Note
              </label>
              <input
                type="text"
                value={formData.note}
                onChange={(e) =>
                  setFormData({ ...formData, note: e.target.value })
                }
                placeholder="Optional note"
                className="w-full bg-gray-800 border-gray-700 rounded-xl px-4 py-2.5 text-white focus:ring-2 focus:ring-blue-500/50 outline-none transition-all"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading || users.length === 0 || !formData.user_id}
            className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Recording..." : "Record Attendance"}
          </button>
        </form>
        {error && !error.includes("not logged in as admin") && (
          <div className="mt-4 bg-red-500/10 text-red-400 p-3 rounded-xl border border-red-500/20">
            {error}
          </div>
        )}
        {users.length === 0 && (
          <p className="mt-2 text-sm text-gray-500">
            No users found. Make sure you are logged in as admin and have users
            available.
          </p>
        )}
      </div>

      {/* Tabs */}
      <div className="bg-gray-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/5 overflow-hidden">
        <div className="border-b border-gray-800">
          <div className="flex">
            <button
              onClick={() => setActiveTab("today")}
              className={`px-8 py-4 font-bold text-sm uppercase tracking-wider transition-all ${
                activeTab === "today"
                  ? "bg-blue-600/10 text-blue-400 border-b-2 border-blue-500"
                  : "text-gray-500 hover:text-gray-300 hover:bg-white/5"
              }`}
            >
              Today
            </button>
            <button
              onClick={() => setActiveTab("history")}
              className={`px-8 py-4 font-bold text-sm uppercase tracking-wider transition-all ${
                activeTab === "history"
                  ? "bg-blue-600/10 text-blue-400 border-b-2 border-blue-500"
                  : "text-gray-500 hover:text-gray-300 hover:bg-white/5"
              }`}
            >
              History
            </button>
          </div>
        </div>

        <div className="p-6">
          {loading ? (
            <div className="text-center py-8 text-gray-500">Loading...</div>
          ) : activeTab === "today" ? (
            <div>
              <h3 className="text-lg font-bold mb-6 text-white flex items-center justify-between">
                <span>Today's Roster</span>
                <span className="bg-blue-600/20 text-blue-400 text-xs px-3 py-1 rounded-full">
                  {todayAttendance.length} Records
                </span>
              </h3>
              {todayAttendance.length === 0 ? (
                <p className="text-gray-500 text-center py-12 italic">
                  No attendance records for today
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-900/50 text-gray-400">
                      <tr>
                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-widest">
                          Employee
                        </th>
                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-widest">
                          Role
                        </th>
                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-widest">
                          Status
                        </th>
                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-widest">
                          Note
                        </th>
                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-widest">
                          Time
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                      {todayAttendance.map((record) => (
                        <tr
                          key={record.id}
                          className="hover:bg-white/5 transition-colors"
                        >
                          <td className="px-4 py-3">
                            {record.user?.username || "-"}
                          </td>
                          <td className="px-4 py-3">
                            <span className="capitalize">
                              {record.user?.role || "-"}
                            </span>
                          </td>
                          <td className="px-4 py-3">
                            <span
                              className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusBadge(
                                record.status,
                              )}`}
                            >
                              {record.status}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-gray-600">
                            {record.note || "-"}
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-500">
                            {formatDate(record.created_at)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          ) : (
            <div>
              <h3 className="text-lg font-semibold mb-4">
                Attendance History ({allAttendance.length})
              </h3>
              {allAttendance.length === 0 ? (
                <p className="text-gray-500 text-center py-8">
                  No attendance history
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-900/50 text-gray-400">
                      <tr>
                        <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-widest">
                          Date
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-widest">
                          Employee
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-widest">
                          Role
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-widest">
                          Status
                        </th>
                        <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-widest">
                          Note
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                      {allAttendance.map((record) => (
                        <tr
                          key={record.id}
                          className="hover:bg-white/5 transition-colors"
                        >
                          <td className="px-4 py-3 text-sm">
                            {formatDate(record.date)}
                          </td>
                          <td className="px-4 py-3">
                            {record.user?.username || "-"}
                          </td>
                          <td className="px-4 py-3">
                            <span className="capitalize">
                              {record.user?.role || "-"}
                            </span>
                          </td>
                          <td className="px-4 py-3">
                            <span
                              className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusBadge(
                                record.status,
                              )}`}
                            >
                              {record.status}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-gray-600">
                            {record.note || "-"}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

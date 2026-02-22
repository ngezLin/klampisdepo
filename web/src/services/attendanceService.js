import api from "./api";

export const attendanceService = {
  // Create new attendance record
  createAttendance: async (data) => {
    const response = await api.post("/attendance/", data);
    return response.data;
  },

  // Get today's attendance
  getTodayAttendance: async () => {
    const response = await api.get("/attendance/today");
    return response.data;
  },

  // Get all attendances
  getAttendances: async () => {
    const response = await api.get("/attendance/");
    return response.data;
  },

  // Get attendance history
  getAttendanceHistory: async () => {
    const response = await api.get("/attendance/history");
    return response.data;
  },
};

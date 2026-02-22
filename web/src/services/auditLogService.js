import api from "./api";

export const getAuditLogs = async (params = {}) => {
  const res = await api.get("/audit-logs/", { params });
  return res.data;
};

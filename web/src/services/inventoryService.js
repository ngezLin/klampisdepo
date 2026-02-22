import api from "./api";

export const getInventoryHistory = async (
  page = 1,
  limit = 10,
  filters = {},
) => {
  const params = { page, limit, ...filters };
  const res = await api.get("/inventory/history", { params });
  return res.data;
};

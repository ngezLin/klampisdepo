import api from "./api";

export const getTransactionHistory = async (
  page = 1,
  limit = 10,
  date = "",
) => {
  const params = { page, limit };
  if (date) params.date = date;

  const res = await api.get("/transactions/history/by-date", { params });
  return res.data;
};

export const getTransactionById = async (id) => {
  const res = await api.get(`/transactions/${id}`);
  return res.data;
};

export const refundTransaction = async (id) => {
  const res = await api.post(`/transactions/${id}/refund`);
  return res.data;
};

export const getItems = async (params = {}) => {
  // Map common params if needed, or pass directly. Backend ItemService uses page_size.
  // We ensure page_size is sent if limit is passed, or just pass params.
  const queryParams = { ...params };
  if (queryParams.limit) {
    queryParams.page_size = queryParams.limit;
    delete queryParams.limit;
  }
  const res = await api.get("/items/", { params: queryParams });
  const data = res.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data.data)) return data.data;
  if (Array.isArray(data.items)) return data.items;

  console.error("getItems(): unexpected response format", data);
  return [];
};

export const getItemsPaginated = async (params = {}) => {
  const queryParams = { ...params };
  if (queryParams.limit) {
    queryParams.page_size = queryParams.limit;
    delete queryParams.limit;
  }
  const res = await api.get("/items/", { params: queryParams });
  return res.data; // Returns { data: [...], page: 1, limit: 10, total: 100, ... }
};

export const getDraftTransactions = async () => {
  const res = await api.get("/transactions/drafts");
  return res.data;
};

export const createTransaction = async (payload) => {
  const res = await api.post("/transactions/", payload);
  return res.data;
};

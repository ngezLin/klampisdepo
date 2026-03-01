import api from "./api.service";

export const getTransactionHistory = (
  page: number = 1,
  limit: number = 10,
  date?: string
) => {
  return api.get(
    date ? "/transactions/history/by-date" : "/transactions/history",
    {
      params: { page, limit, date },
    }
  );
};

export const getTransactionById = (id: number) => {
  return api.get(`/transactions/${id}`);
};

export const refundTransaction = (id: number) => {
  return api.post(`/transactions/${id}/refund`);
};

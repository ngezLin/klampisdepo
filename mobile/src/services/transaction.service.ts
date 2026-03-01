import api from "./api.service"; // axios instance kamu

export interface TransactionItemPayload {
  item_id: number;
  quantity: number;
  customPrice?: number;
}

export interface CreateTransactionPayload {
  status: "draft" | "completed";
  paymentAmount?: number;
  paymentType?: string;
  note?: string;
  transaction_type?: string;
  discount?: number;
  items: TransactionItemPayload[];
}

export const createTransaction = (payload: CreateTransactionPayload) => {
  return api.post("/transactions", payload);
};

export const getTransactions = () => {
  return api.get("/transactions");
};

export const getTransactionById = (id: number) => {
  return api.get(`/transactions/${id}`);
};

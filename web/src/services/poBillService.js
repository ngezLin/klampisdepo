import api from "./api";

export const getPOBills = async (status = "", sortBy = "") => {
  const params = {};
  if (status) params.status = status;
  if (sortBy) params.sort_by = sortBy;

  const res = await api.get("/po-bills/", { params });
  return res.data;
};

export const getPOBillByID = async (id) => {
  const res = await api.get(`/po-bills/${id}`);
  return res.data;
};

export const createPOBill = async (data) => {
  const res = await api.post("/po-bills/", data);
  return res.data;
};

export const updatePOBill = async (id, data) => {
  const res = await api.put(`/po-bills/${id}`, data);
  return res.data;
};

export const markAsPaid = async (id) => {
  const res = await api.put(`/po-bills/${id}/pay`);
  return res.data;
};

export const deletePOBill = async (id) => {
  const res = await api.delete(`/po-bills/${id}`);
  return res.data;
};

export const uploadReceipt = async (file) => {
  const formData = new FormData();
  formData.append("image", file);

  const res = await api.post("/upload/image", formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return res.data; // e.g. { url: "/uploads/img_x.jpg" }
};

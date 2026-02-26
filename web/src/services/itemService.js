import api from "../services/api";

export const getItems = async (page = 1, pageSize = 100) => {
  const res = await api.get("/items/", {
    params: { page, page_size: pageSize },
  });
  return res.data;
};

export const searchItemsByName = async (name, page = 1, pageSize = 100) => {
  const res = await api.get("/items/search", {
    params: { name, page, page_size: pageSize },
  });
  return res.data;
};

export const getItemById = async (id) => {
  const res = await api.get(`/items/${id}`);
  return res.data;
};

export const createItem = async (data) => {
  const res = await api.post("/items/", data);
  return res.data;
};

export const updateItem = async (id, data) => {
  const res = await api.put(`/items/${id}`, data);
  return res.data;
};

export const deleteItem = async (id) => {
  const res = await api.delete(`/items/${id}`);
  return res.data;
};

export const getPublicItems = async (page = 1, pageSize = 100) => {
  const res = await api.get("/public/items", {
    params: { page, page_size: pageSize },
  });
  return res.data;
};

export const searchPublicItemsByName = async (
  name,
  page = 1,
  pageSize = 100,
) => {
  const res = await api.get("/public/items/search", {
    params: { name, page, page_size: pageSize },
  });
  return res.data;
};

export const importItems = async (items) => {
  const res = await api.post("/items/bulk", items);
  return res.data;
};

export const exportItemsCSV = async () => {
  const res = await api.get("/items/export/csv", {
    responseType: "blob",
  });
  return res.data;
};

export const uploadImage = async (file) => {
  const formData = new FormData();
  formData.append("image", file);

  const res = await api.post("/upload/image", formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return res.data; // e.g., { url: "/uploads/img_x.jpg" }
};

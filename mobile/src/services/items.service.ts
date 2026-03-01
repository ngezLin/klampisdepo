import api from "./api.service";

export const getItems = (page: number = 1, pageSize: number = 10) => {
  return api.get("/items", {
    params: { page, page_size: pageSize },
  });
};

export const searchItems = (
  name: string,
  page: number = 1,
  pageSize: number = 10
) => {
  return api.get("/items/search", {
    params: { name, page, page_size: pageSize },
  });
};

export const createItem = (data: any) => api.post("/items", data);

export const updateItem = (id: number, data: any) =>
  api.put(`/items/${id}`, data);

export const deleteItem = (id: number) => api.delete(`/items/${id}`);

import api from "./api";

export const getInventoryHistory = async (
  page = 1,
  limit = 10,
  filters = {},
) => {
  // Filter out empty strings/nulls from filters
  const cleanFilters = Object.fromEntries(
    Object.entries(filters).filter(
      ([_, v]) => v !== "" && v !== null && v !== undefined,
    ),
  );

  const params = { page, limit, ...cleanFilters };
  const res = await api.get("/inventory/history", { params });
  return res.data;
};

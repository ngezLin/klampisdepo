import api from "./api";

const cashSessionService = {
  getCurrentSession: async () => {
    return await api.get("/cash-sessions/current");
  },

  openSession: async (openingCash) => {
    return await api.post("/cash-sessions/open", { opening_cash: openingCash });
  },

  closeSession: async (closingCash) => {
    return await api.post("/cash-sessions/close", {
      closing_cash: closingCash,
    });
  },

  getHistory: async (params) => {
    return await api.get("/cash-sessions/history", { params });
  },
};

export default cashSessionService;

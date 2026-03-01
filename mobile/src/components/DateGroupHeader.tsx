import { View, Text } from "react-native";

export default function DateGroupHeader({ date }: { date: string }) {
  return (
    <View
      style={{
        paddingVertical: 6,
        paddingHorizontal: 10,
        backgroundColor: "#f1f5f9",
        marginVertical: 8,
        borderRadius: 6,
      }}
    >
      <Text style={{ fontWeight: "bold" }}>
        {new Date(date).toDateString()}
      </Text>
    </View>
  );
}

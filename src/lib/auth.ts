import { betterAuth } from "better-auth";
// import { mongooseAdapter } from "better-auth/adapters/mongoose"; // Verify adapter import based on documentation
// import mongoose from "mongoose";

export const auth = betterAuth({
    // database: mongooseAdapter(mongoose.connection), // Uncomment and configure adapter
    emailAndPassword: {
        enabled: true
    },
    // Add other providers here
});

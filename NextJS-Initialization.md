# AI-Ready Architectural Blueprint: Next.js 16 Modular Scalable Stack

**AI INSTRUCTION**: This document serves as a Master Specification. When generating the project, you must analyze the user's specific decisions regarding State Management, Database, and Authentication.

> **CRITICAL**: Before executing any `npm install` or `npx` command, you **MUST** perform a web search to verify the latest stable version and updated syntax for the specific library (especially for Next.js 16, Better-Auth, and Motion).

---

## 1. Requirements Specification Document (RSD)

### Functional Requirements
- **FR-001: Component Animations**: Integration of fluid UI transitions using the `motion` library (ensure compatibility with React 19/Next 16).
- **FR-002: Dynamic Data Fetching**: Centralized HTTP client management via Axios with interceptor support.
- **FR-003: Architectural Flexibility**: A "Plug-and-Play" architecture where State Management, Databases, and Auth are optional modules that can be skipped or added without breaking core logic.

### Non-Functional Requirements
- **NFR-001: Performance**: Mandatory use of Next.js 16 Turbopack (`--turbo`) for development.
- **NFR-002: Scalability**: Strict adherence to the `src/` directory structure to allow the app to grow from a landing page to a complex SaaS.
- **NFR-003: Type Safety**: 100% TypeScript coverage for all generated files and interfaces.

---

## 2. Technical Specification Document (TSD)

### Phase 1: Core Foundation (Mandatory)
- **Framework**: Next.js 16.x (App Router)
- **Styling**: Tailwind CSS 4.0+ (or latest compatible)
- **UI Components**: Shadcn UI (Radix-based)
- **Animations**: Motion (`motion/react`)
- **HTTP Client**: Axios

### Phase 2: Selection Modules (User Selectable)
*AI: Only implement these if the user explicitly requests them.*

#### Decision A: State Management
- **Redux Toolkit**: For complex, enterprise-level global state.
- **Zustand**: For high-performance, lightweight hook-based state.
- **None**: Default. Use React Context or Server State.

#### Decision B: Database Layer
- **PostgreSQL (pg)**: Relational.
- **MySQL (mysql2)**: Relational.
- **MongoDB (mongoose)**: NoSQL.
- **None**: Default. Use for static or API-only apps.

#### Decision C: Authentication System
- **Clerk**: Managed SaaS Auth (Proprietary).
- **Better-Auth**: Self-hosted, database-agnostic auth.
- **None**: Default. Public access only.

---

## 3. Implementation Workflow (AI Instructions)

### Step 1: Initialization
The AI must first ask the user for the **Project Path** and **Modular Decisions**.

### Step 2: Configuration & Installation
**AI Search Requirement**: Verify `npx shadcn@latest init` flags for Next.js 16 before running.

```bash
# --- BASE SETUP ---
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
npm install axios motion
npm install -D @types/node

# --- SHADCN CONFIGURATION ---
# 1. Update tsconfig.json and tsconfig.app.json with:
# "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["./src/*"] } }

# 2. Update vite.config.ts (if applicable) with @ alias and tailwindcss/vite plugin.

# 3. Initialize Shadcn
npx shadcn@latest init
# AI: Prompt user: "Which color would you like to use as base color?" (Default: Zinc)

# --- OPTIONAL MODULES (Select only based on user decision) ---
# State: npm install @reduxjs/toolkit react-redux OR npm install zustand
# DB:    npm install pg OR npm install mysql2 OR npm install mongoose
# Auth:  npm install @clerk/nextjs OR npm install better-auth
```

### Step 3: Environment Setup
If an Authentication system is selected, generate a `.env.local` file but leave specific keys empty.

**Clerk Selection**:
```env
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=
```
*AI Action: Instruct user to sign up at Clerk.com and paste keys.*

**Better-Auth Selection**:
```env
BETTER_AUTH_SECRET=
BETTER_AUTH_URL=http://localhost:3000
```
*AI Action: Generate a secure secret for the user (e.g., `openssl rand -base64 32`).*

### Step 4: Final Review & Execution
1. **Summary**: Present chosen architecture (e.g., "Core Stack + Zustand + PostgreSQL + Better-Auth").
2. **Review Request**: Ask: "Here is the configuration plan. Would you like to review everything one last time before I begin the installation?"
3. **Execution**: Upon confirmation, proceed with commands and file generation.

---

## 4. Sitemap & File Structure

```text
src/
├── app/                  # Routing & Server Components
│   ├── (auth)/           # Optional: Sign-in/Sign-up (Clerk/Better-Auth)
│   └── dashboard/        # Optional: Protected Layouts
├── components/           # UI Components
│   ├── ui/               # Shadcn primitives
│   ├── shared/           # Global reusables (Header/Footer)
│   └── features/         # Feature-specific logic (e.g., /auth-form)
├── hooks/                # Custom React Hooks
├── layouts/              # Reusable Layout Wrappers
├── lib/                  # Utilities (axios.ts, db.ts, auth.ts)
├── state/                # Optional: Redux Slices or Zustand Stores
├── types/                # Global TS Interfaces
└── middleware.ts         # Optional: Auth Route Protection
```

---

## 5. Development Standards

### API & Data Fetching (Axios)
Establish a singleton instance in `src/lib/axios.ts`:
- **Dynamic Base URL**: Use `process.env.NEXT_PUBLIC_API_URL` with a fallback to `/api`.
- **Standard Headers**: Inject `Content-Type: application/json`.
- **Interceptors**: 
  - *Request*: Placeholder for Auth headers (verify provider requirements first).
  - *Response*: Global error handling for logging and UI notifications (Toasts).

### Database Persistence
If a DB is selected, implement a connection pool/singleton in `src/lib/db.ts` to prevent multiple instances during hot-reloads.

### UI Consistency
Always use Shadcn components as the foundation.
```tsx
import { Button } from "@/components/ui/button"
import { motion } from "motion/react"

export const AnimatedButton = () => (
  <motion.div whileHover={{ scale: 1.05 }}>
    <Button>Action</Button>
  </motion.div>
)
```

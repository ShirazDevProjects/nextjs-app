FROM node:22-alpine AS base

# Install libc6-compat for process compatibility if needed on Alpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# ----------------------------------------------------
# Dependencies Stage
# ----------------------------------------------------
FROM base AS deps
WORKDIR /app

# Install dependencies based on package-lock.json
COPY package.json package-lock.json ./
RUN npm ci

# ----------------------------------------------------
# Builder Stage
# ----------------------------------------------------
FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Disable telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build standalone application
RUN npm run build

# ----------------------------------------------------
# Production Runner Stage
# ----------------------------------------------------
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create unprivileged user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy static assets and public directory
COPY --from=builder /app/public ./public

# Set directory permissions for runtime cache
RUN mkdir .next && chown nextjs:nodejs .next

# Leverage Next.js standalone output to keep the image minimal (~150MB)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]

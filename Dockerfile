FROM node:16.13.0-alpine AS development

RUN apk add --no-cache make gcc g++ python3

COPY ./ ./

RUN npm install --legacy-peer-deps

CMD ["/bin/sh", "-c", "npx hardhat run scripts/deploy_contracts.ts --network hardhat"]
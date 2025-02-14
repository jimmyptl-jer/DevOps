# Use the official Node.js image from Docker Hub as the base image
FROM node:23

# Set the working directory inside the container
WORKDIR /usr/src/app

# Set the environment to 'production' for optimized dependency installation
ENV NODE_ENV production

# Suppress experimental warnings
ENV NODE_OPTIONS="--no-warnings"

# Echo the Node.js version
RUN echo "Node.js version:" && node --version

# Echo the npm version
RUN echo "npm version:" && npm --version

# Copy only the package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install only production dependencies using the new omit flag
RUN npm ci --only=production

# Switch to a non-root user to improve security
USER node

# Copy the rest of the application source code from the host to the container
COPY --chown=node:node ./src .

# Expose port 3000 to allow communication with the containerized application
EXPOSE 3000

# Specify the command to run the application
CMD ["node", "app.js"]

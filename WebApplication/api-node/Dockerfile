# Use the official Node.js image from Docker Hub as the base image
# This provides a pre-configured environment with Node.js installed.
FROM node:23

# Set the working directory inside the container
# All subsequent instructions (COPY, RUN, etc.) will use this directory as the current directory.
WORKDIR /usr/src/app

# Set the environment to 'production' for optimized dependency installation
ENV NODE_ENV production

# Check the version of Node.js installed in the image
# This helps to verify the Node.js version during the build process.
RUN echo "Node.js version:" && node --version


# Check the version of npm installed in the image
# This verifies the npm version as well.
RUN echo "npm version:" && npm --version


# Copy only the package.json and package-lock.json files to the working directory
# This helps to leverage Docker's caching mechanism, so dependencies are only installed if these files change.
COPY package*.json ./

# Install only production dependencies based on package-lock.json
RUN npm ci --only=production

# Switch to a non-root user to improve security
USER node

# Copy the rest of the application source code from the host to the container
# This includes all application files from the `src` directory, but not `node_modules` since it was installed in the previous step.
COPY --chown=node:node ./src .

# Expose port 3000 to allow communication with the containerized application
EXPOSE 3000

# Specify the command to run the application
# In this case, we're telling Docker to execute `node index.js` when the container starts.
CMD ["node", "index.js"]

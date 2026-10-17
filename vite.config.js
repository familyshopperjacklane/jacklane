import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  // Repository path for GitHub Pages deployment.
  base: '/jacklane/'
});

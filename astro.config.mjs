// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import sitemap from "@astrojs/sitemap";

import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  site: "https://domenico-tenace-open-labs.github.io/spellbook-of-script/",
  integrations: [
    starlight({
      title: "Spellbook of Script",
      description:
        "A collection of bash scripts designed to automate everyday work, streamline workflows, and manage system operations.",
      components: {
        Head: "./src/components/StarlightHead.astro",
      },
      customCss: ["./src/styles/global.css"],
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/DomeT99/spellbook-of-script",
        },
      ],
      favicon: "/favicon.ico",
      head: [
        {
          tag: "meta",
          attrs: { name: "description", content: "A collection of bash scripts designed to automate everyday work, streamline workflows, and manage system operations." },
        },
        {
          tag: "meta",
          attrs: { property: "og:type", content: "website" },
        },
        {
          tag: "meta",
          attrs: { property: "og:site_name", content: "Spellbook of Script" },
        },
        {
          tag: "meta",
          attrs: { property: "og:title", content: "Spellbook of Script | Bash Automation Scripts" },
        },
        {
          tag: "meta",
          attrs: { property: "og:description", content: "A collection of bash scripts designed to automate everyday work, streamline workflows, and manage system operations." },
        },
        {
          tag: "meta",
          attrs: { property: "og:image", content: "/og-image.svg" },
        },
        {
          tag: "meta",
          attrs: { name: "twitter:card", content: "summary_large_image" },
        },
        {
          tag: "meta",
          attrs: { name: "twitter:title", content: "Spellbook of Script | Bash Automation Scripts" },
        },
        {
          tag: "meta",
          attrs: { name: "twitter:description", content: "A collection of bash scripts designed to automate everyday work, streamline workflows, and manage system operations." },
        },
        {
          tag: "meta",
          attrs: { name: "twitter:image", content: "/og-image.svg" },
        },
        {
          tag: "meta",
          attrs: { name: "keywords", content: "bash, script, automation, shell, terminal, command-line, devops, productivity, workflow" },
        },
      ],
    }),
    sitemap(),
  ],

  vite: {
    plugins: [tailwindcss()],
  },
});

<template>
  <div>
    <div id="map"></div>
  </div>
</template>

<script>
import { Map } from "maplibre-gl";
import Mapa_IFSGA from "../mapa/Mapa_IFSGA.js";
export default {
  data() {
    return {
      Mapa_IFSGA,
      map: null,
      dadosApi: [
        {
          numero: "10",
          ativa: true,
        },
      ],
    };
  },
  mounted() {
    this.carregar_Mapa();
    this.map.on("style.load", () => {
      this.iniciar();
    });
  },
  methods: {
    carregar_Mapa() {
      this.map = new Map({
        container: "map",
        style:
          "https://api.maptiler.com/maps/bright/style.json?key=ilE21IfSV7WArCeJaIvR",
        center: [-35.3381934, -5.7898333],
        zoom: 18,
        hash: true,
      });
    },
    iniciar() {
      this.carregar_source();
      this.carregar_layer_sala_off();
      this.carregar_layer_sala_on();
      this.carregar_layer_geral();
      this.clique_sala();
    },

    carregar_source() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id) {
          this.map.addSource(`${sala.properties.id}-source`, {
            type: "geojson",
            data: sala,
          });
        }
      });
    },

    carregar_layer_geral() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id) {
          //adiciona a linha a sala
          this.map.addLayer({
            id: `${sala.properties.id}-line`,
            type: "line",
            source: `${sala.properties.id}-source`,
            paint: {
              "line-color": "#808080",
              "line-width": 2,
            },
          });

          //adiciona o nome a sala e se a sala não tiver o nome, ele adiciona o ref
        }
      });
    },

    //aqui carrega o layer da sala off
    carregar_layer_sala_off() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id) {
          if (!sala.properties.numero) {
            this.map.addLayer({
              id: `${sala.properties.id}-layer`,
              type: "fill",
              source: `${sala.properties.id}-source`,
              paint: {
                "fill-color": "#fefee2",
              },
            });
            if (sala.properties.name) {
              this.map.addLayer({
                id: `${sala.properties.id}-name`,
                type: "symbol",
                source: `${sala.properties.id}-source`,
                layout: {
                  "text-field": `${sala.properties.name}`,
                  "text-size": 14,
                  "text-max-width": 5,
                },
                paint: {
                  "text-color": "#667",
                  "text-halo-color": "#ffffff",
                  "text-halo-width": 1,
                },
              });
            } else if (sala.properties.ref) {
              this.map.addLayer({
                id: `${sala.properties.id}-ref`,
                type: "symbol",
                source: `${sala.properties.id}-source`,
                layout: {
                  "text-field": `${sala.properties.ref}`,
                  "text-size": 14,
                  "text-max-width": 5,
                },
                paint: {
                  "text-color": "#667",
                  "text-halo-color": "#ffffff",
                  "text-halo-width": 1,
                },
              });
            }
          }
        }
      });
    },

    carregar_layer_sala_on() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id) {
          if (sala.properties.numero) {
            if (this.checarSalaAtiva(sala.properties.numero)) {
              this.map.addLayer({
                id: `${sala.properties.id}-layer`,
                type: "fill",
                source: `${sala.properties.id}-source`,
                paint: {
                  "fill-color": "#D4EDFF",
                },
              });
            }

            if (sala.properties.name) {
              this.map.addLayer({
                id: `${sala.properties.id}-school-icon`,
                type: "symbol",
                source: `${sala.properties.id}-source`,
                layout: {
                  "icon-image": "school",
                  "icon-size": 1.5, // Tamanho do ícone
                  "text-field": `${sala.properties.name}`,
                  "text-variable-anchor": ["top"],
                  "text-justify": "auto",
                  "text-max-width": 9,
                  "text-offset": [0, 1.5],
                  "text-padding": 2,
                  "text-size": 12,
                },
                paint: {
                  "text-color": "#667",
                  "text-halo-blur": 0.5,
                  "text-halo-color": "#ffffff",
                  "text-halo-width": 1,
                },
              });
            } else if (sala.properties.ref) {
              this.map.addLayer({
                id: `${sala.properties.id}-school-icon`,
                type: "symbol",
                source: `${sala.properties.id}-source`,
                layout: {
                  "icon-image": "school",
                  "icon-size": 0.5, // Tamanho do ícone
                  "text-field": `${sala.properties.ref}`,
                  "text-variable-anchor": ["top"],
                  "text-justify": "auto",
                  "text-max-width": 9,
                  "text-offset": [0, 1.5],
                  "text-padding": 2,
                  "text-size": 12,
                },
                paint: {
                  "text-color": "#667",
                  "text-halo-blur": 0.5,
                  "text-halo-color": "#ffffff",
                  "text-halo-width": 1,
                },
              });
            }
          }
        }
        /*}*/
      });
    },

    //método que chega se a sala está ativa, ele puxa a informação da api do ssc
    checarSalaAtiva(salaNumero) {
      for (let i = 0; i < this.dadosApi.length; i++) {
        if (this.dadosApi[i].numero == salaNumero)
          return this.dadosApi[i].ativa;
      }
    },

    //método que pega o clique do usuário na sala
    clique_sala() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        this.map.on("mouseenter", `${sala.properties.id}-layer`, () => {
          this.map.getCanvas().style.cursor = "pointer";
        });
        this.map.on("mouseleave", `${sala.properties.id}-layer`, () => {
          this.map.getCanvas().style.cursor = "";
        });
        //função que pega o clique do usuário no leyer
        this.map.on("click", `${sala.properties.id}-layer`, () => {
          console.log("click!");
        });
      });
    },
  },
};
</script>

<style>
#map {
  margin: 0;
  padding: 0;
  height: 100vh;
}
</style>

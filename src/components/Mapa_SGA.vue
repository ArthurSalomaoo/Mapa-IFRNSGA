/*
 Esse arquivo carrega o mapa do MapTiler(esse mapa é o que fica em baixo do mapa interno)  e o mapa interno do IFRN-SGA
*/

<template>
  <div>
    <div id="map"></div>
    <div id="level-controls">
      <button v-for="level in availableLevels" :key="level" @click="setLevel(level)">
        {{ level }}
      </button>
    </div>
    <div id="search-controls">
      <input v-model="searchQuery" placeholder="Pesquisar sala pelo nome" />
      <button @click="pesquisarSala">Pesquisar</button>
    </div>
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
      currentLevel: "0",
      availableLevels: [],

      //TODO: adicionar todas as salas do ifrn sga que estão listadas no pdf. Depois ir no Mapa_IFSGA.js e adicionar o número das salas que estão faltando
      dadosApi: [
        {
          numero: "21",
          ativa: true,
        },
        {
          numero: "45",
          ativa: true,
        },
        {
          numero: "74",
          ativa: true,
        },
        {
          numero: "46",
          ativa: true,
        },
        {
          numero: "48",
          ativa: true,
        },
        {
          numero: "50",
          ativa: true,
        },
        {
          numero: "51",
          ativa: true,
        },
        {
          numero: "64",
          ativa: true,
        },
        {
          numero: "65",
          ativa: true,
        },
        {
          numero: "70",
          ativa: true,
        },
        {
          numero: "12",
          ativa: true,
        },
        {
          numero: "14",
          ativa: true,
        },
        {
          numero: "28",
          ativa: true,
        },
        {
          numero: "53",
          ativa: true,
        },
        {
          numero: "58",
          ativa: true,
        },
        {
          numero: "68",
          ativa: true,
        },
        {
          numero: "69",
          ativa: true,
        },
        {
          numero: "74",
          ativa: true,
        },
      ],
    };
  },
  mounted() {
    // Método que carrega o Mapa
    this.carregar_Mapa();

    // Quando o mapa do MapTiler for carregado, o método this.iniciar será chamado, os métodos que o this.iniciar chama, precisa do mapa carregado.
    this.map.on("style.load", () => {
      this.iniciar();
    });
  },
  methods: {
    // Método que puxa o mapa do MapLibre
    carregar_Mapa() {
      this.map = new Map({
        container: "map",
        style:
          "https://api.maptiler.com/maps/bright/style.json?key=ilE21IfSV7WArCeJaIvR",
        // Coordenadas do IFRN-SGA
        center: [-35.3381934, -5.7898333],
        zoom: 18,
        hash: true,
      });
    },

    // Método que chama todos os métodos que carregam o estilo do mapa e outras coisas do mapa.
    iniciar() {
      this.carregar_source();
      this.carregar_layer_sala_off();
      this.carregar_layer_sala_on();
      this.clique_sala();
      this.atualizarNiveis();
    },

    // Método que adiciona os dados do mapa que ficará em cima do mapa do MapTiler
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

    // Método que da o estilo das salas OFF
    carregar_layer_sala_off() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id && sala.properties.level === this.currentLevel) {
          if (!sala.properties.numero) {
            this.map.addLayer({
              id: `${sala.properties.id}-layer`,
              type: "fill",
              source: `${sala.properties.id}-source`,
              paint: {
                "fill-color": "#fefee2",
              },
            });
            this.map.addLayer({
              id: `${sala.properties.id}-line`,
              type: "line",
              source: `${sala.properties.id}-source`,
              paint: {
                "line-color": "#808080",
                "line-width": 2,
              },
            });

            // adiciona o nome a sala e se a sala não tiver o nome ele adiciona o ref
            if (sala.properties.name || sala.properties.ref) {
              this.map.addLayer({
                id: `${sala.properties.id}-school-icon`,
                type: "symbol",
                source: `${sala.properties.id}-source`,
                layout: {
                  "text-field": `${
                    sala.properties.name || sala.properties.ref
                  }`,
                  "text-radial-offset": 0,
                  "text-justify": "auto",
                  "text-max-width": 8,
                  "text-padding": 2,
                  "text-offset": [0, 0.6],
                  "text-size": 12,
                },
                paint: {
                  "text-color": "#667",
                  "text-halo-blur": 0.5,
                  "text-halo-color": "#ffffff",
                  "text-halo-width": 1,
                  "text-opacity": [
                    "interpolate",
                    ["linear"],
                    ["zoom"],
                    19,
                    0, // O texto é completamente transparente (desaparece) no zoom 12
                    19.5,
                    1, // O texto é totalmente opaco no zoom 14
                  ],
                },
              });
            }
          }
        }
      });
    },

    // Método que carrega as salas que tem o SSC e da a cor #D4EDFF para as que estiverem ativa
    carregar_layer_sala_on() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.id && sala.properties.level === this.currentLevel) {
          if (sala.properties.numero) {
            if (this.checar_sala_ativa(sala.properties.numero)) {
              this.map.addLayer({
                id: `${sala.properties.id}-layer`,
                type: "fill",
                source: `${sala.properties.id}-source`,
                paint: {
                  "fill-color": "#D4EDFF",
                },
              });
            } else {
              this.map.addLayer({
                id: `${sala.properties.id}-layer`,
                type: "fill",
                source: `${sala.properties.id}-source`,
                paint: {
                  "fill-color": "#fefee2",
                },
              });
            }

            this.map.addLayer({
              id: `${sala.properties.id}-line`,
              type: "line",
              source: `${sala.properties.id}-source`,
              paint: {
                "line-color": "#808080",
                "line-width": 2,
              },
            });

            // adiciona o nome a sala e se a sala não tiver o nome, ele adiciona o ref
            this.map.addLayer({
              id: `${sala.properties.id}-school-icon`,
              type: "symbol",
              source: `${sala.properties.id}-source`,
              layout: {
                "icon-image": "school",
                "icon-size": 1.5,
                "text-field": `${sala.properties.name || sala.properties.ref}`,
                "text-variable-anchor": ["top"],
                "text-radial-offset": 1,
                "text-justify": "auto",
                "text-max-width": 8,
                "text-padding": 2,
                "text-offset": [0, 0.6],
                "text-size": 12,
              },
              paint: {
                "text-color": "#667",
                "text-halo-color": "#ffffff",
                "text-halo-width": 1,
                "text-opacity": [
                  "interpolate",
                  ["linear"],
                  ["zoom"],
                  19,
                  0, // O texto é completamente transparente (desaparece) no zoom 12
                  19.5,
                  1, // O texto é totalmente opaco no zoom 14
                ],
                "icon-opacity": [
                  "interpolate",
                  ["linear"],
                  ["zoom"],
                  19,
                  0, // O texto é completamente transparente (desaparece) no zoom 12
                  19.5,
                  1, // O texto é totalmente opaco no zoom 14
                ],
              },
            });
          }
        }
        /*}*/
      });
    },

    // método que checa se a sala está ativa, ele puxa a informação da api do ssc
    checar_sala_ativa(salaNumero) {
      for (let i = 0; i < this.dadosApi.length; i++) {
        if (this.dadosApi[i].numero == salaNumero)
          return this.dadosApi[i].ativa;
      }
    },

    // Método que recebe o número da sala para mudar a cor da mesma
    mudar_cor_sala(sala_numero, on_off) {
      console.log("oi");
      console.log("on_off", on_off);
      console.log("numero", sala_numero);
      if (on_off) {
        Mapa_IFSGA[0].features.forEach((sala) => {
          if (sala.properties.numero == sala_numero)
            this.map.setPaintProperty(
              `${sala.properties.id}-layer`,
              "fill-color",
              "#D4EDFF"
            );
        });
      } else if (!on_off) {
        Mapa_IFSGA[0].features.forEach((sala) => {
          if (sala.properties.numero == sala_numero)
            this.map.setPaintProperty(
              `${sala.properties.id}-layer`,
              "fill-color",
              "#faafee"
            );
        });
      }
    },

    // Método que pega o clique do usuário na sala
    clique_sala() {
      Mapa_IFSGA[0].features.forEach((sala) => {
        this.map.on("mouseenter", `${sala.properties.id}-layer`, () => {
          this.map.getCanvas().style.cursor = "pointer";
        });
        this.map.on("mouseleave", `${sala.properties.id}-layer`, () => {
          this.map.getCanvas().style.cursor = "";
        });

        // Método que pega o clique do usuário no layer
        this.map.on("click", `${sala.properties.id}-layer`, () => {
          // quando o usuário clicar na sala, chamo a função do arquivo mqtt e passo o número da sala
          this.$emit("exibir_modal", sala.properties.numero);
          console.log(sala.properties.id);
        });
      });
    },
    atualizarNiveis() {
      const levels = new Set();
      Mapa_IFSGA[0].features.forEach((sala) => {
        if (sala.properties.level) {
          levels.add(sala.properties.level);
        }
      });
      this.availableLevels = Array.from(levels).sort();
    },

    setLevel(level) {
      this.currentLevel = level;

      this.map.getStyle().layers.forEach((layer) => {
        if (
          layer.id.endsWith("-layer") ||
          layer.id.endsWith("-line") ||
          layer.id.endsWith("-school-icon")
        ) {
          this.map.removeLayer(layer.id);
        }
      });

      this.carregar_layer_sala_off();
      this.carregar_layer_sala_on();
    },

pesquisarSala() {
  let salaEncontrada = Mapa_IFSGA[0].features.find(
    (sala) => sala.properties.name && sala.properties.name.toLowerCase() === this.searchQuery.toLowerCase()
  );

  if (!salaEncontrada) {
    salaEncontrada = Mapa_IFSGA[0].features.find(
      (sala) => sala.properties.ref && sala.properties.ref.toLowerCase() === this.searchQuery.toLowerCase()
    );
  }

  if (salaEncontrada) {
    this.centralizarEShowModal(salaEncontrada);
  } else {
    alert("Sala não encontrada");
  }
},

centralizarEShowModal(sala) {
  const coordinates = sala.geometry.coordinates[0];
  if (Array.isArray(coordinates) && coordinates.length > 0) {
    const center = this.calcularCentro(coordinates);
    this.map.flyTo({
      center: center,
      zoom: 20,
    });

    // Emitir evento para exibir modal
    this.$emit("exibir_modal", sala.properties.name || sala.properties.ref);
  } else {
    console.error("As coordenadas da sala não estão no formato esperado:", coordinates);
  }
},

calcularCentro(coordinates) {
  let lngSum = 0, latSum = 0;
  coordinates.forEach(coord => {
    lngSum += coord[0];
    latSum += coord[1];
  });
  const lng = lngSum / coordinates.length;
  const lat = latSum / coordinates.length;
  return [lng, lat];
}

  
  },
};
</script>

<style>
#map {
  margin: 0;
  padding: 0;
  height: 100vh;
}
#level-controls {
  position: absolute;
  top: 10px;
  right: 10px;
  background: white;
  padding: 10px;
  border-radius: 4px;
}
#level-controls button {
  display: block;
  margin-bottom: 5px;
}
#search-controls {
  position: absolute;
  top: 50px;
  background: white;
  padding: 10px;
  border-radius: 4px;
  display: flex;
  gap: 5px;
}
</style>

<template>
  <MQTT_Conexao ref="MQTT_Conexao" @mudar_cor_sala="mudar_cor_sala" />
  <Mapa_SGA ref="Mapa_SGA" @exibir_dados="exibir_dados" />
</template>

<script>
import MQTT_Conexao from "./components/MQTT_Conexao.vue";
import Mapa_SGA from "./components/Mapa_SGA.vue";
export default {
  name: "App",
  components: {
    MQTT_Conexao,
    Mapa_SGA,
  },

  methods: {
    mudar_cor_sala(sala_numero, on_off) {
      this.$refs.Mapa_SGA.mudar_cor_sala(sala_numero, on_off);
    },
    exibir_dados(sala_numero) {
      // Chama a função exibir_dados() do componente MQTT_Conexao
      this.$refs.MQTT_Conexao.exibir_dados(sala_numero);
    },
  },
};
</script>

<style>
#app {
  margin: 0;
  padding: 0;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>

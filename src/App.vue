<template>
  <!--<MQTT_Conexao/>-->
  <Mapa_SGA/>
</template>

<script>
//import MQTT_Conexao from './components/MQTT_Conexao.vue';
import Mapa_SGA from './components/Mapa_SGA.vue'
export default {
  name: 'App',
  components: {
    //MQTT_Conexao,
    Mapa_SGA
  }
}
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

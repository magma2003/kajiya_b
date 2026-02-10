const validateRut = (rut) => {
  if (!/^[0-9]+[-|‐][0-9kK]{1}$/.test(rut)) return false;
  const tmp = rut.split('-');
  let digv = tmp[1];
  const cuerpo = tmp[0];
  if (digv === 'K') digv = 'k';

  let suma = 0;
  let multiplo = 2;

  for (let i = 1; i <= cuerpo.length; i++) {
    suma = suma + multiplo * cuerpo.charAt(cuerpo.length - i);
    if (multiplo < 7) multiplo = multiplo + 1;
    else multiplo = 2;
  }

  const dvEsperado = 11 - (suma % 11);
  let dv = dvEsperado === 11 ? '0' : dvEsperado === 10 ? 'k' : dvEsperado.toString();

  return dv === digv;
};

module.exports = { validateRut };
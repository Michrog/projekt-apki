function test()
{
  let test = "test";
  console.log(test);
}

document.addEventListener('turbolinks:load', () => {
  const bbody = document.body;
  bbody.addEventListener('load', (event) => {
    test();
  })
})

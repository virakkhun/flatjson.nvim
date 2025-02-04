type R = Record<string, unknown>;

/**
 * @function flattenObject
 * @param o - Record<string, unknown>
 * @description a function to flat the object recursively
 * @returns {Record<string, unknown>}
 */
function flattenObject<T extends R>(o: T): R {
  return Object.entries(o).reduce(
    (acc, [key, value]) => {
      if (typeof value === "object" && value !== null) {
        const nestedObject = flattenObject(<R>value);

        for (const [k, v] of Object.entries(nestedObject)) {
          const nestedKey = [key, ".", k].join("");
          acc[nestedKey] = v;
        }
      } else {
        acc[key] = value;
      }

      return acc;
    },
    <R>{},
  );
}

/**
 * @function main
 *
 * @description
 * a function to read the content from given path, taking from command line args
 * then parse in to object and flat it
 * write it the console
 *
 * @returns {void}
 */
function main(): void {
  const path = Deno.args.at(0);
  if (path) {
    const content = Deno.readTextFileSync(path);
    const json = JSON.parse(content);
    const flatted = flattenObject(json);
    console.log(JSON.stringify(flatted, null, 2));
  }
}

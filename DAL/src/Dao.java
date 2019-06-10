public interface Dao<T> {
    Schema<T> create(Schema<T>);
    Schema<T> read(Schema<T>);
    Schema<T> update(Schema<T>);
    Schema<T> delete(Schema<T>);
}
